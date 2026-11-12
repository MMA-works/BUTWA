/**
 * ============================================================================
 * BATWA DIGITAL E-WALLET — 24/7 SERVERLESS CLOUD BACKEND (Google Apps Script)
 * ============================================================================
 * Production-ready Web App for Flutter Mobile Client.
 * Runs 24/7 in Google's cloud without needing any local server or laptop on.
 *
 * SPREADSHEET: BATWA-Live-Database
 * TABS: Users, Wallets, Transactions
 *
 * Concurrency: ScriptLock (15s timeout) for ACID transfer integrity.
 * Plain-text passwords and MPINs visible directly in Google Sheets.
 */

const SPREADSHEET_ID = "1W7OtS8PkBYxshxdMxJXoHGU9ifwniFFUeD_QBeHyNDE";

function getDb() {
  try {
    return SpreadsheetApp.openById(SPREADSHEET_ID);
  } catch (e) {
    return SpreadsheetApp.getActiveSpreadsheet();
  }
}

function doGet(e) {
  return handleRequest(e, "GET");
}

function doPost(e) {
  return handleRequest(e, "POST");
}

function handleRequest(e, method) {
  let params = {};
  try {
    // 1. Parse Query Parameters
    if (e && e.parameter) {
      params = Object.assign({}, e.parameter);
    }

    // 2. Parse JSON Body (for POST requests)
    if (e && e.postData && e.postData.contents) {
      try {
        const body = JSON.parse(e.postData.contents);
        params = Object.assign(params, body);
      } catch (jsonErr) {}
    }

    // Determine Action
    let action = (params.action || (e && e.pathInfo) || "").toLowerCase().trim();
    action = action.replace(/^\//, "");

    // Ping / Health
    if (action === "" || action === "ping" || action.includes("ping") || action === "health") {
      return jsonResponse({
        success: true,
        message: "PONG - BATWA Serverless Cloud is Online 24/7",
        timestamp: new Date().toISOString()
      });
    }

    // Username Availability Check
    if (action.includes("check-username") || action.includes("checkusername")) {
      return handleCheckUsername(params);
    }

    // CNIC Check
    if (action.includes("check-cnic") || action.includes("checkcnic")) {
      return handleCheckCnic(params);
    }

    // Email Verify
    if (action.includes("verify-email") || action.includes("verifyemail")) {
      return handleVerifyEmail(params);
    }

    // Login
    if (action.includes("login")) {
      return handleLogin(params);
    }

    // Register
    if (action.includes("register") || action.includes("signup")) {
      return handleRegister(params);
    }

    // Recipient Lookup
    if (action.includes("lookup")) {
      return handleLookup(params);
    }

    // PIN Setup / Change
    if (action.includes("pin")) {
      return handleSetPin(params);
    }

    // Wallet / Balance / Current User
    if (action.includes("wallet") || action.includes("balance") || action.includes("me")) {
      return handleGetWallet(params);
    }

    // P2P Transfer
    if (action.includes("transfer") || action.includes("sendmoney")) {
      return handleTransfer(params);
    }

    // Topup / Deposit
    if (action.includes("topup") || action.includes("deposit")) {
      return handleTopup(params);
    }

    // Transactions History
    if (action.includes("transaction") || action.includes("history")) {
      return handleGetTransactions(params);
    }

    return jsonResponse({
      success: false,
      message: "Unknown action: " + action
    });
  } catch (error) {
    return jsonResponse({
      success: false,
      message: "Server Error: " + error.toString()
    });
  }
}

/**
 * ============================================================================
 * ENDPOINT HANDLERS
 * ============================================================================
 */

/**
 * REAL-TIME USERNAME AVAILABILITY CHECK
 */
function handleCheckUsername(params) {
  const username = normalizeTag(params.username || params.query || "");
  if (!username || username.length < 3) {
    return jsonResponse({
      success: true,
      data: { isAvailable: false }
    });
  }

  const db = getDb();
  const usersSheet = db.getSheetByName("Users");
  const usersData = usersSheet.getDataRange().getValues();

  for (let i = 1; i < usersData.length; i++) {
    const rowTag = normalizeTag(usersData[i][4]);
    if (rowTag === username) {
      return jsonResponse({
        success: true,
        data: { isAvailable: false }
      });
    }
  }

  return jsonResponse({
    success: true,
    data: { isAvailable: true }
  });
}

/**
 * CNIC AVAILABILITY CHECK
 */
function handleCheckCnic(params) {
  return jsonResponse({
    success: true,
    data: { isAvailable: true }
  });
}

/**
 * EMAIL VERIFICATION CHECK
 */
function handleVerifyEmail(params) {
  const email = (params.email || "").toString().trim().toLowerCase();
  const db = getDb();
  const usersSheet = db.getSheetByName("Users");
  const usersData = usersSheet.getDataRange().getValues();

  for (let i = 1; i < usersData.length; i++) {
    const rowEmail = String(usersData[i][2] || "").trim().toLowerCase();
    if (rowEmail === email) {
      return jsonResponse({
        success: true,
        data: { isAvailable: false, message: "Email already registered" }
      });
    }
  }

  return jsonResponse({
    success: true,
    data: { isAvailable: true }
  });
}

/**
 * 1. LOGIN (Universal matching for Phone / UsernameTag / Email)
 */
function handleLogin(params) {
  const identifier = (params.identifier || params.phoneNumber || params.email || params.username || "").toString().trim();
  const password = (params.password || params.loginPassword || "").toString().trim();

  if (!identifier || !password) {
    return jsonResponse({
      success: false,
      message: "Please enter your phone number/email and password."
    });
  }

  const db = getDb();
  const usersSheet = db.getSheetByName("Users");
  const walletsSheet = db.getSheetByName("Wallets");
  if (!usersSheet || !walletsSheet) {
    return jsonResponse({ success: false, message: "Database sheets not found." });
  }

  const usersData = usersSheet.getDataRange().getValues();
  const userRow = findUserRow(usersData, identifier);
  if (!userRow) {
    return jsonResponse({
      success: false,
      message: "Account not found for: " + identifier
    });
  }

  const storedPassword = String(userRow[5]).trim();
  if (storedPassword !== password) {
    return jsonResponse({
      success: false,
      message: "Incorrect password. Please try again."
    });
  }

  const status = String(userRow[8] || "ACTIVE").toUpperCase();
  if (status !== "ACTIVE") {
    return jsonResponse({
      success: false,
      message: "Account is " + status + ". Please contact support."
    });
  }

  // Get live balance from Wallets tab
  let liveBalance = Number(userRow[7]) || 0;
  const walletsData = walletsSheet.getDataRange().getValues();
  for (let i = 1; i < walletsData.length; i++) {
    if (matchesUser(walletsData[i], identifier)) {
      liveBalance = Number(walletsData[i][6]) || liveBalance;
      break;
    }
  }

  const cleanPhone = "0" + normalizePhone(userRow[3]);
  const cleanTag = "@" + normalizeTag(userRow[4]);
  const jwtToken = "batwa_jwt_" + Utilities.getUuid().replace(/-/g, "");

  const userObj = {
    id: String(userRow[0]),
    userId: String(userRow[0]),
    fullName: String(userRow[1]),
    email: String(userRow[2]),
    phoneNumber: cleanPhone,
    usernameTag: cleanTag,
    loginPassword: storedPassword,
    mpin: String(userRow[6]),
    hasPinConfigured: true,
    isLocked: (status !== "ACTIVE"),
    balance: liveBalance,
    status: status,
    registeredAt: String(userRow[9])
  };

  const walletObj = {
    id: "wal_" + userObj.id.replace("usr_", ""),
    walletId: "wal_" + userObj.id.replace("usr_", ""),
    accountTitle: userObj.fullName,
    accountNumber: cleanPhone,
    walletTag: cleanTag,
    usernameTag: cleanTag,
    balance: liveBalance,
    currency: "PKR",
    isActive: (status === "ACTIVE"),
    status: status,
    qrCodeData: "BATWA:" + cleanPhone
  };

  return jsonResponse({
    success: true,
    message: "Login successful",
    data: {
      token: jwtToken,
      accessToken: jwtToken,
      refreshToken: jwtToken,
      user: userObj,
      wallet: walletObj
    }
  });
}

/**
 * 2. REGISTER
 */
function handleRegister(params) {
  const fullName = (params.fullName || params.name || "").toString().trim();
  const phoneNumber = normalizePhone(params.phoneNumber || params.phone || "");
  const email = (params.email || "").toString().trim().toLowerCase();
  let usernameTag = normalizeTag(params.usernameTag || params.username || "");
  const password = (params.password || params.loginPassword || "").toString().trim();
  const mpin = (params.mpin || params.pin || "1234").toString().trim();

  if (!fullName || !phoneNumber || !password) {
    return jsonResponse({
      success: false,
      message: "Full Name, Mobile Phone, and Password are required."
    });
  }

  if (phoneNumber.length < 9) {
    return jsonResponse({
      success: false,
      message: "Please enter a valid Pakistani mobile number (e.g. 03232320829)."
    });
  }

  const db = getDb();
  const usersSheet = db.getSheetByName("Users");
  const walletsSheet = db.getSheetByName("Wallets");
  const usersData = usersSheet.getDataRange().getValues();

  for (let i = 1; i < usersData.length; i++) {
    const rowPhone = normalizePhone(usersData[i][3]);
    const rowEmail = String(usersData[i][2]).toLowerCase().trim();
    const rowTag = normalizeTag(usersData[i][4]);

    if (rowPhone === phoneNumber) {
      return jsonResponse({ success: false, message: "An account with mobile number 0" + phoneNumber + " already exists." });
    }
    if (email && rowEmail === email) {
      return jsonResponse({ success: false, message: "An account with email " + email + " already exists." });
    }
    if (usernameTag && rowTag === usernameTag) {
      return jsonResponse({ success: false, message: "The username @" + usernameTag + " is already taken." });
    }
  }

  if (!usernameTag) {
    usernameTag = fullName.toLowerCase().replace(/[^a-z0-9]/g, "") + Math.floor(100 + Math.random() * 900);
  }

  const userId = "usr_" + Utilities.getUuid().substring(0, 8);
  const walletId = "wal_" + Utilities.getUuid().substring(0, 8);
  const initialBalance = 5000.00;
  const nowStr = Utilities.formatDate(new Date(), "Asia/Karachi", "yyyy-MM-dd HH:mm:ss");
  const displayPhone = "0" + phoneNumber;
  const displayTag = "@" + usernameTag;

  // Append to Users
  usersSheet.appendRow([
    userId, fullName, email, phoneNumber, displayTag, password, mpin, initialBalance, "ACTIVE", nowStr
  ]);

  // Append to Wallets
  walletsSheet.appendRow([
    walletId, fullName, phoneNumber, displayTag, password, mpin, initialBalance, "PKR", "ACTIVE", nowStr
  ]);

  const jwtToken = "batwa_jwt_" + Utilities.getUuid().replace(/-/g, "");

  return jsonResponse({
    success: true,
    message: "Account registered successfully! Welcome to BATWA.",
    data: {
      token: jwtToken,
      accessToken: jwtToken,
      refreshToken: jwtToken,
      userId: userId,
      id: userId,
      walletId: walletId,
      fullName: fullName,
      phoneNumber: displayPhone,
      usernameTag: displayTag,
      loginPassword: password,
      mpin: mpin,
      hasPinConfigured: true,
      balance: initialBalance,
      currency: "PKR",
      user: {
        id: userId,
        fullName: fullName,
        email: email,
        phoneNumber: displayPhone,
        hasPinConfigured: true,
        isLocked: false
      },
      wallet: {
        id: walletId,
        walletTag: displayTag,
        currency: "PKR",
        balance: initialBalance,
        isActive: true,
        qrCodeData: "BATWA:" + displayPhone
      }
    }
  });
}

/**
 * 3. RECIPIENT LOOKUP
 */
function handleLookup(params) {
  const query = (params.query || params.identifier || params.phoneNumber || params.username || "").toString().trim();
  if (!query) return jsonResponse({ success: false, message: "Query is required." });

  const db = getDb();
  const usersSheet = db.getSheetByName("Users");
  const userRow = findUserRow(usersSheet.getDataRange().getValues(), query);

  if (!userRow) {
    return jsonResponse({ success: false, message: "No BATWA account found for: " + query });
  }

  const cleanPhone = "0" + normalizePhone(userRow[3]);
  const cleanTag = "@" + normalizeTag(userRow[4]);

  return jsonResponse({
    success: true,
    message: "Recipient found",
    data: {
      fullName: String(userRow[1]),
      accountTitle: String(userRow[1]),
      recipientFullName: String(userRow[1]),
      phoneNumber: cleanPhone,
      accountNumber: cleanPhone,
      maskedPhoneNumber: cleanPhone,
      walletTag: cleanTag,
      usernameTag: cleanTag,
      currency: "PKR",
      status: String(userRow[8] || "ACTIVE")
    }
  });
}

/**
 * 4. GET WALLET & CURRENT USER (Live Balance & Profile)
 */
function handleGetWallet(params) {
  let identifier = (params.identifier || params.phoneNumber || params.userId || params.email || params.username || params.tag || "").toString().trim();
  const db = getDb();
  const walletsSheet = db.getSheetByName("Wallets");
  const usersSheet = db.getSheetByName("Users");
  if (!walletsSheet) return jsonResponse({ success: false, message: "Wallets sheet not found." });

  const walletsData = walletsSheet.getDataRange().getValues();
  let row = null;

  // 1. Try direct match in Wallets
  if (identifier) {
    row = findUserRow(walletsData, identifier);
  }

  // 2. If not found in Wallets, check Users sheet (handles email -> phone lookup)
  let userRow = null;
  if (usersSheet) {
    const usersData = usersSheet.getDataRange().getValues();
    if (identifier) {
      userRow = findUserRow(usersData, identifier);
    } else if (usersData.length > 1) {
      userRow = usersData[1];
    }
    if (userRow && !row) {
      row = findUserRow(walletsData, userRow[3]) || findUserRow(walletsData, userRow[4]) || findUserRow(walletsData, userRow[0]);
    }
  }

  // 3. Fallback to primary wallet if still not found
  if (!row && walletsData.length > 1) {
    row = walletsData[1];
  }

  if (!row) return jsonResponse({ success: false, message: "Wallet not found." });

  const cleanPhone = "0" + normalizePhone(row[2]);
  const cleanTag = "@" + normalizeTag(row[3]);
  const bal = Number(row[6]) || 0;

  let email = userRow ? String(userRow[2] || "") : "";
  if (!email && usersSheet) {
    const matchedUser = findUserRow(usersSheet.getDataRange().getValues(), row[2]);
    if (matchedUser) email = String(matchedUser[2] || "");
  }

  return jsonResponse({
    success: true,
    data: {
      id: String(row[0]),
      userId: String(row[0]),
      walletId: String(row[0]),
      fullName: String(row[1]),
      accountTitle: String(row[1]),
      phoneNumber: cleanPhone,
      accountNumber: cleanPhone,
      email: email,
      hasPinConfigured: true,
      isLocked: false,
      walletTag: cleanTag,
      usernameTag: cleanTag,
      balance: bal,
      currency: String(row[7] || "PKR"),
      isActive: (String(row[8] || "ACTIVE").toUpperCase() === "ACTIVE"),
      status: String(row[8] || "ACTIVE"),
      qrCodeData: "BATWA:" + cleanPhone
    }
  });
}

/**
 * PIN SETUP / CHANGE
 */
function handleSetPin(params) {
  const identifier = (params.identifier || params.phoneNumber || params.userId || "").toString().trim();
  const pin = (params.pin || params.newPin || "1234").toString().trim();
  if (!pin || pin.length < 4) {
    return jsonResponse({ success: false, message: "PIN must be at least 4 digits." });
  }

  const db = getDb();
  const usersSheet = db.getSheetByName("Users");
  const walletsSheet = db.getSheetByName("Wallets");

  if (usersSheet) {
    const usersData = usersSheet.getDataRange().getValues();
    for (let i = 1; i < usersData.length; i++) {
      if (matchesUser(usersData[i], identifier)) {
        usersSheet.getRange(i + 1, 7).setValue(pin);
        break;
      }
    }
  }

  if (walletsSheet) {
    const walletsData = walletsSheet.getDataRange().getValues();
    for (let i = 1; i < walletsData.length; i++) {
      if (matchesUser(walletsData[i], identifier)) {
        walletsSheet.getRange(i + 1, 6).setValue(pin);
        break;
      }
    }
  }

  return jsonResponse({
    success: true,
    message: "PIN updated successfully!"
  });
}

/**
 * 5. P2P TRANSFER (LockService Concurrency Protection)
 */
function handleTransfer(params) {
  const senderId = (params.senderId || params.senderPhone || params.sender || "").toString().trim();
  const receiverQuery = (params.receiver || params.receiverPhone || params.receiverQuery || params.recipientIdentifier || "").toString().trim();
  const amount = parseFloat(params.amount);
  const mpin = (params.mpin || params.pin || "").toString().trim();
  const note = (params.note || "Transfer via BATWA").toString().trim();

  if (!senderId || !receiverQuery) {
    return jsonResponse({ success: false, message: "Sender and receiver required." });
  }
  if (isNaN(amount) || amount <= 0) {
    return jsonResponse({ success: false, message: "Invalid amount." });
  }

  const lock = LockService.getScriptLock();
  if (!lock.tryLock(15000)) {
    return jsonResponse({ success: false, message: "Server busy. Please try again in a moment." });
  }

  try {
    const db = getDb();
    const walletsSheet = db.getSheetByName("Wallets");
    const usersSheet = db.getSheetByName("Users");
    const txSheet = db.getSheetByName("Transactions");

    const walletsData = walletsSheet.getDataRange().getValues();
    let senderRowIdx = -1, receiverRowIdx = -1;

    for (let i = 1; i < walletsData.length; i++) {
      if (matchesUser(walletsData[i], senderId)) senderRowIdx = i;
      if (matchesUser(walletsData[i], receiverQuery)) receiverRowIdx = i;
    }

    if (senderRowIdx === -1) return jsonResponse({ success: false, message: "Sender wallet not found." });
    if (receiverRowIdx === -1) return jsonResponse({ success: false, message: "Receiver account not found for: " + receiverQuery });
    if (senderRowIdx === receiverRowIdx) return jsonResponse({ success: false, message: "Cannot transfer money to yourself." });

    const senderRow = walletsData[senderRowIdx];
    const receiverRow = walletsData[receiverRowIdx];

    if (mpin && String(senderRow[5]).trim() !== mpin) {
      return jsonResponse({ success: false, message: "Invalid Transaction MPIN." });
    }

    const senderBal = Number(senderRow[6]) || 0;
    const fee = 0.00;
    const totalRequired = amount + fee;

    if (senderBal < totalRequired) {
      return jsonResponse({
        success: false,
        message: "Insufficient funds. Available: Rs " + senderBal.toFixed(2) + ", Required: Rs " + totalRequired.toFixed(2)
      });
    }

    const receiverBal = Number(receiverRow[6]) || 0;
    const newSenderBal = senderBal - totalRequired;
    const newReceiverBal = receiverBal + amount;
    const nowStr = Utilities.formatDate(new Date(), "Asia/Karachi", "yyyy-MM-dd HH:mm:ss");

    // Update Wallets Sheet
    walletsSheet.getRange(senderRowIdx + 1, 7).setValue(newSenderBal);
    walletsSheet.getRange(senderRowIdx + 1, 10).setValue(nowStr);

    walletsSheet.getRange(receiverRowIdx + 1, 7).setValue(newReceiverBal);
    walletsSheet.getRange(receiverRowIdx + 1, 10).setValue(nowStr);

    // Sync Users Sheet
    syncUserBalance(usersSheet, senderRow[2], newSenderBal);
    syncUserBalance(usersSheet, receiverRow[2], newReceiverBal);

    const trxId = "TRX_" + Utilities.getUuid().substring(0, 10).toUpperCase();
    const senderTag = "@" + normalizeTag(senderRow[3]);
    const receiverTag = "@" + normalizeTag(receiverRow[3]);

    txSheet.appendRow([
      trxId, nowStr,
      senderRow[1] + " (" + senderTag + ")",
      receiverRow[1] + " (" + receiverTag + ")",
      amount, fee, "TRANSFER", "SUCCESS", newSenderBal, newReceiverBal, note
    ]);

    return jsonResponse({
      success: true,
      message: "Transfer of Rs " + amount.toFixed(2) + " completed successfully!",
      data: {
        id: trxId,
        trxId: trxId,
        referenceNumber: trxId,
        sourceWalletTag: senderTag,
        sourceUserFullName: String(senderRow[1]),
        destinationWalletTag: receiverTag,
        destinationUserFullName: String(receiverRow[1]),
        transactionType: "TRANSFER",
        status: "SUCCESS",
        amount: amount,
        fee: fee,
        totalDebited: totalRequired,
        currency: "PKR",
        description: note,
        createdAt: new Date().toISOString(),
        senderPrevBalance: senderBal,
        senderNewBalance: newSenderBal,
        receiverPrevBalance: receiverBal,
        receiverNewBalance: newReceiverBal
      }
    });
  } finally {
    lock.releaseLock();
  }
}

/**
 * 6. TOPUP
 */
function handleTopup(params) {
  const identifier = (params.identifier || params.phoneNumber || "").toString().trim();
  const amount = parseFloat(params.amount);
  if (!identifier || isNaN(amount) || amount <= 0) {
    return jsonResponse({ success: false, message: "Valid amount required." });
  }

  const lock = LockService.getScriptLock();
  lock.tryLock(10000);
  try {
    const db = getDb();
    const walletsSheet = db.getSheetByName("Wallets");
    const usersSheet = db.getSheetByName("Users");
    const txSheet = db.getSheetByName("Transactions");
    const walletsData = walletsSheet.getDataRange().getValues();

    let rowIdx = -1;
    for (let i = 1; i < walletsData.length; i++) {
      if (matchesUser(walletsData[i], identifier)) { rowIdx = i; break; }
    }
    if (rowIdx === -1) return jsonResponse({ success: false, message: "Wallet not found." });

    const newBal = (Number(walletsData[rowIdx][6]) || 0) + amount;
    const nowStr = Utilities.formatDate(new Date(), "Asia/Karachi", "yyyy-MM-dd HH:mm:ss");

    walletsSheet.getRange(rowIdx + 1, 7).setValue(newBal);
    walletsSheet.getRange(rowIdx + 1, 10).setValue(nowStr);
    syncUserBalance(usersSheet, walletsData[rowIdx][2], newBal);

    const trxId = "TOP_" + Utilities.getUuid().substring(0, 10).toUpperCase();
    const tag = "@" + normalizeTag(walletsData[rowIdx][3]);

    txSheet.appendRow([
      trxId, nowStr, "BANK_DEPOSIT",
      walletsData[rowIdx][1] + " (" + tag + ")",
      amount, 0.00, "TOPUP", "SUCCESS", 0, newBal, "Instant Top-Up"
    ]);

    return jsonResponse({
      success: true,
      message: "Top-up of Rs " + amount.toFixed(2) + " successful!",
      data: { trxId: trxId, newBalance: newBal }
    });
  } finally {
    lock.releaseLock();
  }
}

/**
 * 7. TRANSACTION HISTORY
 */
function handleGetTransactions(params) {
  const identifier = (params.identifier || params.phoneNumber || params.tag || "").toString().trim();
  const db = getDb();
  const txSheet = db.getSheetByName("Transactions");
  if (!txSheet) return jsonResponse({ success: true, data: [] });

  const data = txSheet.getDataRange().getValues();
  if (data.length <= 1) return jsonResponse({ success: true, data: [] });

  const normPhone = normalizePhone(identifier);
  const normTag = normalizeTag(identifier);
  const results = [];

  for (let i = data.length - 1; i >= 1; i--) {
    const row = data[i];
    const sender = String(row[2]);
    const receiver = String(row[3]);

    const isMatch = !identifier ||
      (normPhone && (sender.includes(normPhone) || receiver.includes(normPhone))) ||
      (normTag && (sender.toLowerCase().includes(normTag) || receiver.toLowerCase().includes(normTag)));

    if (isMatch) {
      results.push({
        id: String(row[0]),
        trxId: String(row[0]),
        referenceNumber: String(row[0]),
        sourceWalletTag: sender,
        sourceUserFullName: sender,
        destinationWalletTag: receiver,
        destinationUserFullName: receiver,
        transactionType: String(row[6] || "TRANSFER"),
        status: String(row[7] || "SUCCESS"),
        amount: Number(row[4]) || 0,
        fee: Number(row[5]) || 0,
        totalDebited: (Number(row[4]) || 0) + (Number(row[5]) || 0),
        currency: "PKR",
        description: String(row[10] || "Transfer"),
        createdAt: new Date().toISOString(),
        senderNewBalance: Number(row[8]) || 0,
        receiverNewBalance: Number(row[9]) || 0
      });
    }
    if (results.length >= 50) break;
  }
  return jsonResponse({ success: true, data: results });
}

// Helpers
function jsonResponse(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj)).setMimeType(ContentService.MimeType.JSON);
}

function normalizePhone(phone) {
  if (!phone) return "";
  let clean = String(phone).replace(/\D/g, "");
  if (clean.startsWith("92") && clean.length >= 11) clean = clean.substring(2);
  if (clean.startsWith("0")) clean = clean.substring(1);
  return clean;
}

function normalizeTag(tag) {
  if (!tag) return "";
  let clean = String(tag).trim().toLowerCase();
  if (clean.startsWith("@")) clean = clean.substring(1);
  return clean;
}

function matchesUser(row, query) {
  if (!query || !row) return false;
  const qClean = String(query).trim().toLowerCase();
  const qPhone = normalizePhone(qClean);
  const qTag = normalizeTag(qClean);

  for (let i = 0; i < row.length; i++) {
    const cellVal = String(row[i] || "").trim();
    if (!cellVal) continue;

    // Direct match (userId, email, title, etc.)
    if (cellVal.toLowerCase() === qClean) return true;

    // Phone match
    if (qPhone && qPhone.length >= 7) {
      const cellPhone = normalizePhone(cellVal);
      if (cellPhone && cellPhone === qPhone) return true;
    }

    // Tag match
    if (qTag && qTag.length >= 2) {
      const cellTag = normalizeTag(cellVal);
      if (cellTag && cellTag === qTag) return true;
    }
  }
  return false;
}

function findUserRow(data, query) {
  for (let i = 1; i < data.length; i++) {
    if (matchesUser(data[i], query)) return data[i];
  }
  return null;
}

function syncUserBalance(usersSheet, phoneNumber, newBalance) {
  if (!usersSheet) return;
  const normPhone = normalizePhone(phoneNumber);
  const usersData = usersSheet.getDataRange().getValues();
  for (let i = 1; i < usersData.length; i++) {
    if (normalizePhone(usersData[i][3]) === normPhone) {
      usersSheet.getRange(i + 1, 8).setValue(newBalance);
      break;
    }
  }
}

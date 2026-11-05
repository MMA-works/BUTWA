package com.batwa.wallet.repository;

import com.batwa.wallet.entity.Budget;
import com.batwa.wallet.entity.TransactionCategory;
import com.batwa.wallet.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface BudgetRepository extends JpaRepository<Budget, UUID> {
    List<Budget> findByUserAndMonthPeriod(User user, String monthPeriod);
    Optional<Budget> findByUserAndCategoryAndMonthPeriod(User user, TransactionCategory category, String monthPeriod);
    List<Budget> findByUser(User user);
}

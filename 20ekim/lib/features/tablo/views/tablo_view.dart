import 'package:flutter/material.dart';
import '../controllers/tablo_controller.dart';
import '../models/tablo_model.dart';
import '../widgets/project_selector_bar.dart';
import '../widgets/budget_summary_card.dart';
import '../widgets/resource_chart_card.dart';
import '../widgets/transaction_table_card.dart';
import '../widgets/add_transaction_dialog.dart';
import '../widgets/add_project_dialog.dart';

/// Finansal tablolar, kaynak yönetimi ve proje bütçeleri ana görünümü.
class TabloView extends StatelessWidget {
  final TabloController controller;

  const TabloView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<List<TransactionModel>>(
        valueListenable: controller.transactions,
        builder: (context, _, _) => ValueListenableBuilder<String?>(
          valueListenable: controller.selectedProjectId,
          builder: (context, selectedId, _) => _buildContent(context, selectedId),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransaction(context),
        icon: const Icon(Icons.add),
        label: const Text('İşlem Ekle'),
      ),
    );
  }

  Widget _buildContent(BuildContext context, String? selectedId) {
    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 80),
      children: [
        ValueListenableBuilder<List<ProjectModel>>(
          valueListenable: controller.projects,
          builder: (context, projects, _) => ProjectSelectorBar(
            projects: projects,
            selectedProjectId: selectedId,
            onSelect: controller.selectProject,
            onAddProject: () => _showAddProject(context),
          ),
        ),
        const SizedBox(height: 8),
        BudgetSummaryCard(
          netBalance: controller.netBalance,
          totalIncome: controller.totalIncome,
          totalExpense: controller.totalExpense,
          usageRatio: controller.budgetUsageRatio,
        ),
        ResourceChartCard(
          categoryExpenseMap: controller.categoryExpenseMap,
          totalExpense: controller.totalExpense,
        ),
        TransactionTableCard(
          transactions: controller.filteredTransactions,
          onDelete: controller.deleteTransaction,
        ),
      ],
    );
  }

  void _showAddTransaction(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AddTransactionDialog(
        projects: controller.projects.value,
        defaultProjectId: controller.selectedProjectId.value,
        onAdd: controller.addTransaction,
      ),
    );
  }

  void _showAddProject(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AddProjectDialog(onAdd: controller.addProject),
    );
  }
}

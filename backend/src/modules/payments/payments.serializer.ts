import type { Contribution } from '@prisma/client';

type ContributionAllocationDto = {
  amount: number;
  savingsGoal: { child: { firstName: string } | null };
};

/** DTO cotisation en snake_case (contrat §1). */
export function toContributionDto(
  c: Contribution,
  allocations: ContributionAllocationDto[] = [],
) {
  return {
    id: c.id,
    parent_id: c.parentId,
    amount: c.amount,
    method: c.method,
    reference: c.reference,
    status: c.status,
    collected_by_agent_id: c.collectedByAgentId,
    provider: c.provider,
    provider_reference: c.providerReference,
    target_goal_type: c.targetGoalType ?? null,
    created_at: c.createdAt.toISOString(),
    confirmed_at: c.confirmedAt?.toISOString() ?? null,
    allocations: allocations.map((allocation) => ({
      child_first_name: allocation.savingsGoal.child?.firstName ?? '',
      amount: allocation.amount,
    })),
  };
}

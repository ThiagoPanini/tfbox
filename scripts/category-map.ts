// Mapping: AWS resource type prefix -> catalog category id.
// Order matters (first match wins).
export const RESOURCE_CATEGORY: Array<[RegExp, string]> = [
  [/^aws_lambda_/, "compute"],
  [/^aws_ecs_/, "compute"],
  [/^aws_ec2_|^aws_instance$/, "compute"],
  [/^aws_dynamodb_/, "database"],
  [/^aws_rds_|^aws_db_/, "database"],
  [/^aws_s3_/, "storage"],
  [/^aws_efs_/, "storage"],
  [/^aws_sns_/, "messaging"],
  [/^aws_sqs_/, "messaging"],
  [/^aws_eventbridge_|^aws_cloudwatch_event_/, "messaging"],
  [/^aws_iam_/, "iam"],
  [/^aws_kms_/, "iam"],
  [/^aws_vpc_|^aws_subnet|^aws_security_group|^aws_route/, "networking"],
  [/^aws_api_gateway|^aws_apigatewayv2/, "networking"],
];

export const CATEGORIES = [
  { id: "compute", label: "Compute", hue: "violet" },
  { id: "storage", label: "Storage", hue: "emerald" },
  { id: "database", label: "Database", hue: "amber" },
  { id: "messaging", label: "Messaging", hue: "cyan" },
  { id: "iam", label: "Identity", hue: "rose" },
  { id: "networking", label: "Networking", hue: "sky" },
  { id: "other", label: "Other", hue: "slate" },
] as const;

// Pick the primary resource type for a module: the one whose service segment
// (aws_<service>_*) matches the module directory name, or — failing that — the
// most common service segment across all resources.
export function primaryResource(resourceTypes: string[], moduleName: string): string {
  if (resourceTypes.length === 0) return "";
  const modServiceHints = moduleName.toLowerCase().split(/[-_]/).filter(Boolean);
  const scored = resourceTypes.map((t) => {
    const service = t.match(/^aws_([a-z0-9]+)/)?.[1] ?? "";
    if (!service) return { t, service, score: -100 }; // non-aws (e.g. null_resource)
    const hit = modServiceHints.some((h) => h === service || h.startsWith(service) || service.startsWith(h));
    return { t, service, score: hit ? 10 : 0 };
  });
  // Bump score by service-segment frequency.
  const freq = new Map<string, number>();
  for (const r of scored) freq.set(r.service, (freq.get(r.service) ?? 0) + 1);
  for (const r of scored) r.score += freq.get(r.service) ?? 0;
  scored.sort((a, b) => b.score - a.score);
  return scored[0]!.t;
}

export function inferCategory(resourceTypes: string[], moduleName: string): string {
  const primary = primaryResource(resourceTypes, moduleName);
  for (const [pattern, cat] of RESOURCE_CATEGORY) {
    if (pattern.test(primary)) return cat;
  }
  // Fallback: first matching type across all resources.
  for (const t of resourceTypes) {
    for (const [pattern, cat] of RESOURCE_CATEGORY) {
      if (pattern.test(t)) return cat;
    }
  }
  return "other";
}

// AWS service icon slug inferred from the primary resource.
export function inferIcon(resourceTypes: string[], moduleName: string): string {
  const t = primaryResource(resourceTypes, moduleName);
  const m = t.match(/^aws_([a-z0-9]+)_/);
  return m ? `aws/${m[1]}` : "aws/generic";
}

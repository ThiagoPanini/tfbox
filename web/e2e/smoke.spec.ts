import { test, expect } from "@playwright/test";

test("home → detail → copy snippet golden path", async ({ page, context }) => {
  await context.grantPermissions(["clipboard-read", "clipboard-write"]);
  await page.goto("/");

  await expect(page.getByRole("heading", { level: 1 })).toContainText(/Terraform/i);
  // Every module card renders with a name + stats row.
  await expect(page.locator("article").first()).toBeVisible();

  // Enter a query → narrow grid.
  await page.getByPlaceholder(/Filter modules/i).fill("lambda-function");
  await expect(page.locator("article")).toHaveCount(1);

  // Navigate into detail.
  await page.getByRole("link", { name: /view/i }).first().click();
  await expect(page).toHaveURL(/\/modules\/lambda-function\/?$/);
  await expect(page.getByRole("heading", { level: 1 })).toHaveText("lambda-function");

  // Switch to the Example tab and copy the minimal snippet.
  await page.getByRole("tab", { name: "example" }).click();
  await page.getByRole("button", { name: /copy lambda-function minimal example/i }).click();
  const clipped = await page.evaluate(() => navigator.clipboard.readText());
  expect(clipped).toMatch(/module "lambda-function"/);
  expect(clipped).toMatch(/function_name\s*=\s*"function_name-example"/);
});

test("mobile viewport renders the home grid without overflow (375px)", async ({ page }) => {
  await page.setViewportSize({ width: 375, height: 812 });
  await page.goto("/");
  const scroll = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
  expect(scroll).toBeLessThanOrEqual(1);
});

test("command palette opens with ⌘K and jumps to a module", async ({ page }) => {
  await page.goto("/");
  await page.keyboard.press("ControlOrMeta+k");
  await page.getByPlaceholder(/Jump to module/i).fill("dynamodb");
  await page.getByRole("option").first().click();
  await expect(page).toHaveURL(/\/modules\/dynamodb-table/);
});

# Migrating Terraform: From Flat State to Modular, Environment‑Driven Workflows

A step‑by‑step guide to reorganizing your Terraform codebase for better isolation, reuse, and safe promotions.

---

## 1. Original State Organization

**Layout & Workflow**  
- One root `terraform/` dir with `main.tf`, `variables.tf`, etc.  
- A single state file (`terraform.tfstate`), often backed in S3 or local.  
- Environment separation via manual workspaces or var overrides.  

**Limitations & Pitfalls**  
- State bloat: all resources (dev/staging/prod) colliding in one file.  
- Risky promotions: changing prod resources by accident.  
- Poor modularity: every change to API, IAM, Lambda lives in the same file.  
- No clear boundaries: hard to onboard new team members or delegate responsibilities.

---

## 2. Terraform Module Primer

**What Is a Module?**  
A folder of Terraform code (resources, inputs, outputs) that you can call from another config.  
- **Root module**: your top‑level `main.tf` + friends.  
- **Child modules**: reusable building blocks (e.g. `modules/lambda/`).  

**Benefits**  
- Encapsulation: group related resources (Lambda + aliases + permissions).  
- Reusability: share standard patterns across projects.  
- Customizability: expose inputs (`var.memory_size`, `var.aliases`) and outputs.  
- Versioning: pin module source to a Git tag or registry release.

**How to Use**  
```hcl
module "lambda" {
  source             = "../../modules/lambda"
  functions          = local.lambda_functions
  execution_role_arn = module.iam.execution_role_arn
}
```
- Define inputs (maps, lists, primitives).  
- Consume outputs (`module.lambda.alias_arns["myfunc_dev"]`).  
- Leverage `for_each` / `count` for dynamism.

---

## 3. New Modular, Environment‑Driven Layout

```text
terraform/
├── environments/
│   ├── dev/
│   │   └── main.tf
│   ├── staging/
│   │   └── main.tf
│   └── prod/
│       └── main.tf
└── modules/
    ├── lambda/
    ├── iam/
    ├── api_gateway/
    └── cloudwatch/
```

- **Per‑env dirs**: isolate state, vars, backends.  
- **Modules**: implement core concerns (compute, IAM, logging, API).  
- **Locals & tagging**: define `local.project`, `local.environment`, `local.common_tags` in each env.  

---

## 4. Migration & State Management

1. **Initialize per‑env**  
   ```bash
   cd terraform/environments/dev
   terraform init \
     -backend-config="key=dev/terraform.tfstate"
   ```
2. **Import or Move State**  
   - Use `terraform state list` to see existing resources.  
   - Use `terraform state mv` or `terraform state rm` to rehome resources into new modules.  
   - Example:
     ```bash
     terraform state mv aws_lambda_function.old_lambda \
       module.lambda.aws_lambda_function.functions["ig_post_extractor"]
     ```
3. **Validate with Plan**  
   ```bash
   terraform plan
   ```
   - Confirm no‑ops (resources point to the same physical infra).  
   - Tweak `source_arn`, aliases, or var values as needed.

4. **Promote Across Envs**  
   - Repeat init/import/plan in `staging` and `prod`.  
   - Each env uses its own state backend key (`staging/terraform.tfstate`, etc.).

---

## 5. Verifying Seamless Transition

- **List state**  
  ```bash
  terraform state list
  ```
- **Show resource details**  
  ```bash
  terraform state show module.lambda.aws_lambda_function.functions["ig_post_extractor"]
  ```
- **Plan output**  
  - Zero changes means success.  
  - Any drift indicates a mis‑mapping to correct with `state mv` or var updates.

---

### Outcome

- **Isolation**: each env has its own state, no cross‑contamination.  
- **Modularity**: modules encapsulate best practices and are easily versioned.  
- **Repeatability**: spin up new environments by copying one folder and adjusting vars.  
- **Safety**: `plan` + `state` commands ensure zero‑downtime, controlled migrations.

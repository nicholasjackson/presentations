---
{layout="01 Main Title - Terraform"}

# What's new in Terraform 0.12

## Nic Jackson


---
{layout="09 Section Title - Terraform"}

# An example

<!--
-->


---
{layout="11-3 Code Editor"}

# Terraform 0.11
## main.tf

```ruby
variable "count" {
  default = 1
}

variable "default_prefix" {
  default = "linus"
}

resource "random_pet" "my_pet" {
  count  = "${var.count}"
  prefix = "${var.default_prefix}"
}
```

<!--
sets the stage for the next several slides
nothing complicated about it, just wanted everyone to get the context: 
random provider creating random_pet resources (human-friendly unique id) with a count and my cat's name as a prefix.
This example is going to be the “Default behavior” for the next few examples.  Now we can run terraform apply without overriding any of the variable defaults ... 
-->


---
{layout="11-4 Terminal Window"}

# Terraform 0.11

```bash
terraform apply

random_pet.my_pet: Creating...
  length:    "" => "2"
  prefix:    "" => "linus"
  separator: "" => "-"
random_pet.my_pet: Creation complete after 0s (ID: linus-excited-goldfish)

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

pet_names = [
    Pet: linus-excited-goldfish
]
```

<!--
And tada!
*click*
Today's random_pet string is 'linus_excited_goldfish", which I find delightful. This, however, is boring, so let's see ...
-->


---
{layout="09 Section Title - Terraform"}

# A more complicated example

<!--
-->


---
{layout="11-3 Code Editor"}

# Terraform 0.11
## main.tf

```ruby {style="font-size:30"}
variable "count" { default = 1 }
variable "default_prefix" { default = "linus" }

variable "zoo_enabled" {
  default = "0"
}

variable "prefix_list" {
  default = []
}

resource "random_pet" "my_pet" {
  count  = "${var.count}"
  prefix = "${var.zoo_enabled == "0" ? var.default_prefix : element(var.prefix_list, count.index)}"
}

```

<!--
* default behavior is the same, but refactored for optional additional features. 
* two vars: zoo_enabled, defaulting to 0 (string) and prefix_list, defaults to an empty list.
* prefix now conditional - explain intent 
* explain choice of string for bool
* tfvars next
-->


---
{layout="11-3 Code Editor"}

# Terraform 0.11
## terraform.tfvars

```ruby
zoo_enabled = "1"
prefix_list = [ "linus", "cheetarah", "li-shou"]
count = 3
```

<!--
terraform.tfvars: I'm setting count to three and setting a prefix_list.
Ok, so this is fine and dandy and runs as expected. 
-->


---
{layout="11-4 Terminal Window"}

# Terraform 0.11

```bash
random_pet.my_pet[1]: Creating...
  length:    "" => "2"
  prefix:    "" => "cheetarah"
  separator: "" => "-"
[…] 

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

pet_names = [
    Pet: linus-special-goblin,
    Pet: cheetarah-loyal-drake,
    Pet: li-shou-witty-turtle
]
```

<!--
Yay, 3 pets! cheetarah-loyal-drake <3

But what happens if I remove terraform.tfvars and just go with the defaults? 
-->


---
{layout="11-4 Terminal Window"}

# Terraform 0.11

```bash
$ terraform apply

Error: random_pet.my_pet: 1 error(s) occurred:

* random_pet.my_pet: element: element() may not be used with an empty list in:

${var.zoo_enabled == "0" ? var.default_prefix : element(var.prefix_list, count.index)}
```

<!--
I get this error here: element may not be used with an empty list, 
y, when it should just use the default?
terraform evaluates both sides of the conditional instead of the more intuitive lazy evaluation. 
-->


---
{layout="09 Section Title - Terraform"}

# The hack

<!--
-->


---
{layout="11-3 Code Editor"}

# Terraform 0.11
## terraform.tfvars

```ruby
variable "count" { default = 1 }
variable "default_prefix" { default = "linus" }

variable "zoo_enabled" {
  default = "0"
}

variable "prefix_list" {
  default = []
}

resource "random_pet" "my_pet" {
  count  = "${var.count}"
  prefix = "${var.zoo_enabled == "0" ? var.default_prefix : element(concat(var.prefix_list, list("")), count.index)}"
}
```

<!--
* to ensure that terraform can evaluate this half of the conditional when the list is empty, I add concat function to concatenate a list with a single item - an empty string - to the prefix_list list variable.
* why not default = [""]?
* its more likely that I would be using a list of resources that are only created when zoo_enabled is 1, so I cannot control the contents of the list.
-->


---
{layout="11-4 Terminal Window"}

# Terraform 0.11

```bash
$ terraform apply

random_pet.my_pet: Creating...
  length:    "" => "2"
  prefix:    "" => "linus"
  separator: "" => "-"
random_pet.my_pet: Creation complete after 0s (ID: linus-driving-giraffe)

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

pet_names = [
    Pet: linus-driving-giraffe
]
```

<!--
With that change, things run as expected again. it's gnarly, had to read if you don't know what's going on, but it works
-->


---
{layout="09 Section Title - Terraform"}

# Terraform 0.12

<!--
-->


---
{layout="14 Title at Top"}

## Terraform - Write, Plan, and Create Infrastructure as Code

* HashiCorp Terraform enables you to safely and predictably create, change, and improve infrastructure.  
* It is an open source tool that codifies APIs into declarative configuration files that can be shared amongst team members, treated as code, edited, reviewed, and versioned.
  
<!--
* released in 2014, *THE* tool for defining infrastructure as code
* the tcl provides a high level syntax for describing how cloud resources and services should be created, provisioned, and combined
* tf was pretty awesome as it was, our users came up with really clever and creative ways exercising terraform, stretching it beyond the initial design and eventually coming up on some edge cases and limitations
* users found brilliant hackarounds and took advantage of some accidental features
* HC loves everything y'all were building, wanted to support you, and knew that terraform config language needed to grow, but couldn't build into core w/o refactor
* working on that for the past year
-->


---
{layout="11-3 Code Editor"}

# Terraform 0.11 & Earlier
## HCL - HashiCorp Configuration Language

```ruby 
variable “foo” { 
  default = “bar” 
}
```

---
{layout="11-3 Code Editor"}

# Terraform 0.11 & Earlier
## HIL - HashiCorp Interpolation Language

```ruby
foo = "hello ${var.world}”

“${format(“Hello %s”, var.world)}”
```

---
{layout="14 Title at Top"}

## Terraform Configuration Language - Terraform v0.12

HCL2
* Merges HCL and HIL
* Introduces a robust type system
* Addresses large list of enhancements and feature requests

<!--
0.12 introduces HCL2 - a complete rework for 0.12. 
merges HCL and HIL, enhances the type system
gives contributors to tf repo tools they need to continue expanding terraform's capabilities
-->

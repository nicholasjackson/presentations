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
variable "foo" { 
  default = "bar"
}
```

---
{layout="11-3 Code Editor"}

# Terraform 0.11 & Earlier
## HIL - HashiCorp Interpolation Language

```ruby
foo = "hello ${var.world}"

"${format(“Hello %s”, var.world)}"
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

---
{layout="14 Title at Top"}

## So many improvements

![](https://raw.githubusercontent.com/nicholasjackson/presentations/master/terraform_0_12/images/improvements.png)

<!--
-->

---
{layout="09 Section Title - Terraform"}

# Terraform 0.12 First Class Expressions


---
{layout="14 Title at Top"}

## First-Class Expressions

* operations and variables can be used outside of string interpolation
    * buh-bye "${ }"

* lists and maps can be used directly with expressions 
    * less list(""), more []

<!--
Expressions are native to HCL2 and can be used directly
lists and maps can be used directly, including empty lists / maps (previously required a function)
-->


---
{layout="11-3 Code Editor"}

# Terraform 0.11
## main.tf

```ruby {style="font-size:28"}
variable "ami"           {}
variable "instance_type" {}
variable "vpc_security_group_ids" {
  type = "list"
}

resource "aws_instance" "example" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"

  vpc_security_group_ids = "${var.vpc_security_group_ids}"
}
```

<!--
Here's a simple (and made up) aws resource definition, written in terraform 0.11 syntax.
key bits: var vpc_security_group_ids = list, passed into the aws instance
* now same in 0.12
-->


---
{layout="11-3 Code Editor"}

# Terraform 0.12
## main.tf

```ruby {style="font-size:28"}
variable "ami"           {}
variable "instance_type" {}
variable "vpc_security_group_ids" {
  type = list(string)
}

resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.instance_type

  vpc_security_group_ids = var.vpc_security_group_ids
}
```

<!--
same resource updated for terraform 0.12
Types are now first-class values and don't need to be quoted
variable as a list of strings - we'll take a closer look at types in the next section 
and here are pretty variables sans "${}"
Next: 0.12 feature - using lists and maps directly. Back to 0.11
-->


---
{layout="11-3 Code Editor"}

# Terraform 0.11
## main.tf

```ruby {style="font-size:28"}
variable "ami"           {}
variable "instance_type" {}
variable "vpc_security_group_id" {
  type    = "string"
  default = ""
}

resource "aws_instance" "example" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"

  vpc_security_group_ids = "${var.vpc_security_group_id != "" ?                           
    [var.vpc_security_group_id] : list("") }"
}
```

<!--
Here's another 0.11 example to highlight improvements in lists and maps
Now vpc_secgroup_id is a string, not a list, and there's a conditional statement that helps us pass our string to a resource that requires a list. See that list("") function? Let's look at it in 0.12
-->


---
{layout="11-3 Code Editor"}

# Terraform 0.12
## main.tf

```ruby {style="font-size:28"}
variable "ami"           {}
variable "instance_type" {}
variable "vpc_security_group_id" {
  type    = string
  default = ""
}

resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.instance_type

  vpc_security_group_ids = 
  var.security_group_id != "" ? [var.security_group_id] : []

}
```

<!--
list enhancement! I've refactored my vpc_secgroup_id to be a string so I can show you other neat things we can do with lists now
conditional that directly sets the vpc_security_group_ids to an empty list (right in line) if vpc_security_group_id is empty. 
I can declare an empty list exactly as you'd expect, with plain brackets. 
That's it for first-class exprs, now time for *click* 
-->


---
{layout="09 Section Title - Terraform"}

# Terraform 0.12 - Rich Value Types

<!--
-->


---
{layout="14 Title at Top"}

## First-Class Expressions

* enhances simple type system
* complex values
    * maps and lists! 
    * maps of maps!!
    * maps of lists of maps of lists!!!
* entire resources and modules as values

<!--
while hcl does support basic lists and maps, hcl2 provides a rich type system 
complex values, including entire resources
-->


---
{layout="11-4 Terminal Window"}

# Terraform
## Module layout


```bash
$ tree
.
├── main.tf
├── terraform.tfvars
└── modules
    └── subnets
      └── subnets.tf
```

<!--
next few examples use a module
top-level config in main.tf
modules directory with subnets modules
-->


---
{layout="11-3 Code Editor"}

# Terraform 0.11
## main.tf

```ruby
variable "networks" {
  type = "list"
}

module "subnets" {
source = "./modules/subnets"
  networks = "${var.networks}"
  ...
}

output "vpc_id" {
  value = "${module.subnets.aws_vpc.example.id}"
}
```

<!--
0.11 main.tf using the subnets module
passes a single variable, networks to the module
output must be in the modules
-->


---
{layout="11-3 Code Editor"}

# Terraform 0.11
## main.tf

```ruby
# "subnets" module

variable "networks" {
  type = "list"
}

resource "aws_vpc" "example" {
  networks = "${var.networks}"
  ...
}

output "vpc_id" {
  value = "${aws_vpc.example.id}"
}
```

<!--
"subnets" module which creates an aws_vpc
we use "output" to export the vpc id so it is accessible by top-level main.tf
what if we need access to another attribute from main.tf? 
[click] gotta add it to output.
Let's see this in 0.12
-->


---
{layout="11-3 Code Editor"}

# Terraform 0.12
## main.tf

```ruby
variable "networks" {
  type = map(object({
    network_number    = number
    availability_zone = string
    tags              = map(string)
  }))
}

module "subnets" {
  source = "./modules/subnets"
networks = var.networks
}

output "vpc_id" {
  value = module.subnets.aws_vpc.example.id
}
```

<!--
Same main.tf in 0.12 syntax
declaring "networks" as  a complex map variable with mixed-type values
otherwise the same
look at variable definition 
-->


---
{layout="11-3 Code Editor"}

# Terraform 0.12
## terraform.tfvars

```ruby
networks = {
  "production" = {
    network_number    = 1
    availability_zone = "us-east-1a"
  }
  "staging" = {
    network_number    = 2
    availability_zone = "us-east-1a"
  }
}
```
<!--
... and an example of that variable definition
-->


---
{layout="11-3 Code Editor"}

# Terraform 0.12
## subnets.tf

```ruby {style="font-size:28"}
# "subnets" modules

variable "networks" {
  type = map(object({
    network_number    = number
    availability_zone = string
    tags              = map(string)
  }))
}

resource "aws_vpc" "example" {
  networks = var.networks
  ...
}

output "vpc" {
  value = aws_vpc.example
}
```

<!--
in the subnets module
the entire vpc object is being passed as an output -now you'll have access to all attributes from your top-level configuration. Let's take a look at that.
-->


---
{layout="11-3 Code Editor"}

# Terraform 0.12
## main.tf

```ruby {style="font-size:28"}
variable "networks" {
  type = map(object({
    network_number    = number
    availability_zone = string
    tags              = map(string)
  }))
}

module "subnets" {
source   = "./modules/subnets"
networks = var.networks
}

resource "aws_instance" "my_server" {
subnet_id = module.subnets.aws_vpc.example.id
az = module.subnets.aws_vpc.example.availability_zone
... 
}
```

<!--
builds an AWS instance using attributes subnets module 
can access any of the attributes from the aws_vpc resource, because we output the entire resource. 
next topic is especially exciting to me
-->


---
{layout="09 Section Title - Terraform"}

# Terraform 0.12 - Improved Error Messages

<!--
If you've written terraform code, you've likely found yourself in a situation where you've spent hours trying to make sense of a cryptic error message, only to find out that it was actually a syntax error. 

or maybe you have tens of files with hundreds of lines of configuration with one syntax error. Good luck finding it! 
-->


---
{layout="11-4 Terminal Window"}

# Terraform 0.11

```bash
$ terraform plan

Error: Error parsing main.tf: object expected closing RBRACE got: EOF
```

<!--
Take this example right here. Say you have a thousand line main.tf. Where would you look to fix this error? WHO KNOWS! If you were me, you'd spend the next several minutes steadily commenting out the whole dang file and un-commenting one block at a time trying to find it. 
-->


---
{layout="11-4 Terminal Window"}

# Terraform 0.12

```bash
$ terraform plan

Error: Argument or block definition required

  on main.tf line 24:
  24: :wq

An argument or block definition is required here.
```

<!--
The HCL2 parser retains detailed information about the locations of all tokens and syntax elements, so that error messages can refer to specific source locations.
-->


---
{layout="11-4 Terminal Window"}

# Terraform 0.12

```bash
$ terraform plan

Error: Invalid operand

  on main.tf line 16, in output "foobar":
  16:   value = "${1 + var.foo}"

Unsuitable value for right operand: a number is required.
```

<!--
The message is presented together with a snippet of source code showing the erroneous element in context, including a header identifying the top-level block the snippet is within.
-->


---
{layout="11-4 Terminal Window"}

# Terraform 0.12

```bash
$ terraform plan

Error: Unsupported block type

  on main.tf line 36, in outptu "item":
   1: outptu "item" {

Blocks of type "outptu" are not expected here. Did you mean "output"?
```

<!--
On the surface, "improved error messages" might not sound very glamorous, but as a practitioner who has suffered through trying to figure out what's wrong with my configuration files, I find this very exciting.
-->


---
{layout="09 Section Title - Terraform"}

# There is more!


---
{layout="09 Section Title - Terraform"}

# Terraform 0.12 - For Expressions

<!--
Everyone will like this, and we're getting into the advanced features of special interest to module developers.

The general problem of iteration has been hard to solve. 

Terraform 0.12 introduces a few different features to improve these capabilities, with more enhancements to come in future releases.
-->


---
{layout="14 Title at Top"}

## For Expressions

* **for**: list and map transformations
* **for_each**: for dynamic nested blocks
* **dynamic nested blocks**

<!--
These features greatly enhance our ability to write reusable modules.
for, for_each (for building resources and dynamic blocks) and OH YEAH dynamic nested blocks!
Let's see some 0.12 examples
-->


---
{layout="11-3 Code Editor"}

# Terraform 0.11
## main.tf

```ruby {style="font-size:28"}
output "instance_private_ip_addresses_map" {
  value = "${zipmap(aws_instance.id, aws_instance.private_ip)}"
}
```

<!--
Say I have a list of resource with multiple attributes and I wanted to transform it into a map of instance ids to instance ips. Have a few functions that can help, but a bit janky.
-->


---
{layout="11-3 Code Editor"}

# Terraform 0.12
## main.tf

```ruby
output "instance_private_ip_addresses" {
  value = {
    for instance in aws_instance.example:
    instance.id => instance.private_ip
  }
}
```

<!--
For expressions allows the construction of a list or map by transforming and filtering elements in another list or map
this output starts with a list of aws_instances and creates a new map with instance.id as the key and instance.private_ip as the value - let's see 
-->


---
{layout="11-4 Terminal Window"}

# Terraform 0.12

```bash
$ terraform output

instance_private_ip_addresses = {
  "i-1234" = "192.168.1.1"
  "i-5678" = "192.168.1.2"
  "i-9876" = "192.168.1.3"
}
```


---
{layout="11-3 Code Editor"}

# Terraform 0.11
## main.tf

```ruby {style="font-size:28"}
resource "aws_autoscaling_group" "example" {
  # ...
  tag {
    key                 = "Component"
    value               = "user-service"
    propagate_at_launch = true
  }


 tag {
   key                 = "Environment"
   value               = "production"
   propagate_at_launch = false
 }


tag { ... }
tag { ... }
tag { ... }
tag { ... }
}
```

<!--
* tagging aws autoscaling groups takes forever
-->


---
{layout="11-3 Code Editor"}

# Terraform 0.12
## main.tf

```ruby {style="font-size:28"}
locals {
  standard_tags = {
    Component   = "user-service"
    Environment = "production"
  }
}

resource "aws_autoscaling_group" "example" {
  # ...

  dynamic "tag" {
    for_each = local.standard_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
```

<!--
* dynamic block of tags
for_each
proves that I'm a practitioner 
-->


---
{layout="09 Section Title - Terraform"}

# A true story - Act II


---
{layout="11-3 Code Editor"}

# Terraform 0.11
## main.tf

```ruby {style="font-size:28"}
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
First, a quick refresher - let's take a look back at that ugly conditional hack around she's using: 
-->


---
{layout="09 Section Title - Terraform"}

# The same example - HCL2

<!--
And now the same thing, in HCL2 syntax, with several interesting changes
-->


---
{layout="11-3 Code Editor"}

# Terraform 0.12
## main.tf

```ruby {style="font-size:28"}
variable "pet_count" { default = 1 }

variable "default_prefix" { default = “linus" }

variable "zoo_enabled" {
  default = false
}

variable "prefix_list" {
  default = []
}

resource "random_pet" "my_pet" {
  count  = var.pet_count
  prefix = var.zoo_enabled ? element(var.prefix_list, count.index) : var.default_prefix
}
```

<!--
Count is a reserved variable, changed it to pet_count
100% confident about using a boolean - not worried about refactoring
Cleaner looking - don’t need “${}” anymore
Conditional is shorter (and therefor easier to understand) since I’m using an actual bool
Conditional is lazy evaluated, tf doesn’t care that prefix_list is empty as long as zoo_enabled is false
-->


---
{layout="11-4 Terminal Window"}

# Terraform 0.12

```bash
$ terraform apply
random_pet.my_pet[0]: Creating...
random_pet.my_pet[0]: Creation complete after 0s

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

pet_names = [
    Pet: linus-beloved-mako
]
```


---
{layout="11-3 Code Editor"}

# Terraform 0.11
## HCL

```ruby
prefix = 
  "${var.zoo_enabled == "0" ? var.default_prefix : 
    element(concat(var.prefix_list, list("")), count.index)}"
```


---
{layout="11-3 Code Editor"}

# Terraform 0.12
## HCL2

```ruby
prefix = 
  var.zoo_enabled ? element(var.prefix_list, count.index) : var.default_prefix
```


---
{layout="09 Section Title - Terraform"}

# But what does it mean?

<!--
Terraform 0.12 introduces many features that users have been requesting for years. It's been a long wait, but hopefully now you understand the enormity of the refactoring that this represents and how long we've been working on it.
-->


---
{layout="14 Title at Top"}

## Terraform 0.12 Enhancements

* configuration is easier to read and reason about
* consistent, predictable behavior in complex functions
* improved support for loosely-coupled modules

<!--
so many hackarounds, resolved! 
Its EASIER to write, read, and reason about
pass output from one module to another
-->


---
{layout="Thank You"}

# nic@hashicorp.com
## @sheriffjackson

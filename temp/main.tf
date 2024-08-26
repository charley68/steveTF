variable "service_label" {
 type = string
 default = "steve"
}



variable "existing_network_admin_group_name" {
  type = string
  default = ""
}

variable "rm_existing_network_admin_group_name" {
  type = string
  default = ""
}


locals {
  #------------------------------------------------------------------------------------------------------
  #-- Any of these local variables can be overriden in a _override.tf file
  #------------------------------------------------------------------------------------------------------
  custom_network_admin_group_name = null
  custom_groups_defined_tags = null
  custom_groups_freeform_tags = null
}



locals {


  myMap = {
    abc = 1
    name = "steve"
    male = true
  }

  mything = {
    "Bob" = {
         name="Lilly"
         Age = 6
     },
     "Fred" = {
         name="Olivia"
         Age = 6
     }
}

 # Tags
  landing_zone_tags = {"cis-landing-zone" : fileexists("${path.module}/release.txt") ? "${var.service_label}-quickstart/${file("${path.module}/release.txt")}" : "${var.service_label}-quickstart"}

  default_groups_defined_tags = null
  default_groups_freeform_tags = local.landing_zone_tags

  groups_defined_tags = local.custom_groups_defined_tags != null ? merge(local.custom_groups_defined_tags, local.default_groups_defined_tags) : local.default_groups_defined_tags
  groups_freeform_tags = local.custom_groups_freeform_tags != null ? merge(local.custom_groups_freeform_tags, local.default_groups_freeform_tags) : local.default_groups_freeform_tags


  network_admin_group_key = "${var.service_label}-network-admin-group"
  default_network_admin_group_name = "network-admin-group"
  provided_network_admin_group_name = local.custom_network_admin_group_name != null ? local.custom_network_admin_group_name : "${var.service_label}-${local.default_network_admin_group_name}"
  
  network_admin_group = length(var.existing_network_admin_group_name) == 0 && length(trimspace(var.rm_existing_network_admin_group_name)) == 0 ? {
    (local.network_admin_group_key) = {
      name          = local.provided_network_admin_group_name  
      description   = "CIS Landing Zone group for network management."
      members       = []
      defined_tags  = local.groups_defined_tags
      freeform_tags = local.groups_freeform_tags
    } 
  } : {} 
}

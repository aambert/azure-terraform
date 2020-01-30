# custom image

data "azurerm_shared_image" "scaleset_image_reference" {
  name                = var.scaleset_image_name
  resource_group_name = var.image_resource_group_name
  gallery_name        = var.gallery_name
}






resource "azurerm_virtual_machine_scale_set" "scale-set" {
  name                = "${module.label.name}-${var.name}-scale-set"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = module.label.tags


  


  # automatic rolling upgrade
  automatic_os_upgrade = var.automatic_os_upgrade
  upgrade_policy_mode  = var.upgrade_policy_mode

  rolling_upgrade_policy {
    max_batch_instance_percent              = var.max_batch_instance_percent
    max_unhealthy_instance_percent          = var.max_unhealthy_instance_percent
    max_unhealthy_upgraded_instance_percent = var.max_unhealthy_instance_percent
    pause_time_between_batches              = var.pause_time_between_batches
  }

  # required when using rolling upgrade policy
  health_probe_id = var.health_probe_id

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.capacity
  }

  storage_profile_image_reference {
    id = data.azurerm_shared_image.scaleset_image_reference.id
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = var.disk_size_gb
  }

  os_profile {
    computer_name_prefix = var.computer_name_prefix
    admin_username       = var.admin_username
    admin_password       = var.admin_password
    custom_data          = var.custom_data
  }

  os_profile_windows_config {

    provision_vm_agent        = true
    enable_automatic_upgrades = null
  }


  network_profile {
    name    = "networkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      primary                                = true
      subnet_id                              = var.subnet_id
      load_balancer_backend_address_pool_ids = var.lb_pool_ids
    
    }
  }


}


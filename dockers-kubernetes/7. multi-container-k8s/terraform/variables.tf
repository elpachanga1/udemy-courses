variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for the GKE cluster"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "multi-container-cluster"
}

variable "network" {
  description = "The VPC network to host the cluster in"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "The subnetwork to host the cluster in"
  type        = string
  default     = "default"
}

variable "pods_range_name" {
  description = "The name of the secondary range for pods"
  type        = string
  default     = ""
}

variable "services_range_name" {
  description = "The name of the secondary range for services"
  type        = string
  default     = ""
}

variable "authorized_networks" {
  description = "List of master authorized networks"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "All networks"
    }
  ]
}

variable "maintenance_start_time" {
  description = "Start time for daily maintenance window (HH:MM format)"
  type        = string
  default     = "03:00"
}

variable "network_policy_enabled" {
  description = "Enable network policy addon"
  type        = bool
  default     = false
}

variable "release_channel" {
  description = "The release channel of this cluster (RAPID, REGULAR, STABLE)"
  type        = string
  default     = "REGULAR"
}

variable "node_count" {
  description = "Number of nodes per zone in the node pool"
  type        = number
  default     = 1
}

variable "min_node_count" {
  description = "Minimum number of nodes per zone in the node pool"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes per zone in the node pool"
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "The machine type for the nodes"
  type        = string
  default     = "e2-medium"
}

variable "disk_size_gb" {
  description = "Size of the disk attached to each node"
  type        = number
  default     = 50
}

variable "disk_type" {
  description = "Type of the disk attached to each node"
  type        = string
  default     = "pd-standard"
}

variable "preemptible" {
  description = "Whether to use preemptible nodes"
  type        = bool
  default     = false
}

variable "service_account" {
  description = "The service account to be used by the node VMs"
  type        = string
  default     = ""
}

variable "node_labels" {
  description = "Labels to add to the nodes"
  type        = map(string)
  default = {
    environment = "production"
  }
}

variable "node_tags" {
  description = "Tags to add to the nodes"
  type        = list(string)
  default     = ["gke-node"]
}

variable "credentials_file" {
  description = "Path to the GCP service account credentials JSON file (optional if using gcloud auth)"
  type        = string
  default     = ""
}

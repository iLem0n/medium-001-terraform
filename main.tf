# basic terraform setup (required)
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.3.2"
    }   
  }
}

##########################
# Provider Configuration
##########################
provider "kubernetes" {  
  # configure kubernetes provider with local kube-config
  config_path = "~/.kube/config"
}

provider "helm" {
  # configure helm provider with local kube-config
  kubernetes {
    config_path = "~/.kube/config"     
  }
}

##########################
# Desired Resources
##########################
# let there be a namespace named `my-playground`
resource "kubernetes_namespace" "playground_namespace" {
  metadata {
    name = "my-playground"
  }
}

# create a helm-release from the official argo-cd helm chart repository 
resource "helm_release" "argo_cd_release" {
  name          = "argo-cd"
  namespace     = kubernetes_namespace.playground_namespace.metadata.0.name # <--reference to the created namespace above 
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-cd"

  values        = [
      templatefile("resources/argocd.values.yaml.tftpl", {
          namespace = kubernetes_namespace.playground_namespace.metadata.0.name
      })
  ] 
}
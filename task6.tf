
provider "kubernetes" {
  config_context_cluster = "minikube"
}

provider "aws" {
  region = "ap-south-1"

  profile = "abhi"
}

resource "kubernetes_deployment" "deployment" {
  metadata {
    name = "deployment"
    labels = {
      App = "Webserver"
    }
  }
  spec {
    replicas = 1
    strategy {
      type = "RollingUpdate"
    }
    selector {
      match_labels = {
        env = "Production"
        type = "webserver"
        dc = "India"
      }
    }
    template {
      metadata {
        labels = {
          env = "Production"
          type = "webserver"
          dc = "India"
        }
      }
      spec {
        container {
          name = "webserver"
          image = "wordpress"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "WordPress" {
  metadata {
    name = "wordpress-service"
  }
  spec {
    type = "NodePort"
    selector = {
      type = "webserver"
    }
    port {
      port = 80
      target_port = 80
      protocol = "TCP"
      name = "http"
    }
  }
}

resource "aws_db_instance" "RDS" {
  allocated_storage    = 5
  max_allocated_storage = 7
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"

  identifier           = "wordpressdb"

  name                 = "wordpress"
  username             = "abhi"
  password             = "abhishekarora"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot = true
  port = 3306
  publicly_accessible = true

  auto_minor_version_upgrade = true

  delete_automated_backups = true
}

output "RDS-Instance" {
  value = aws_db_instance.RDS.address
}
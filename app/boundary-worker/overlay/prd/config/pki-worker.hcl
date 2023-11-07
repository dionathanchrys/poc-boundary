# disable memory from being swapped to disk
disable_mlock = true

# listener denoting this is a worker proxy
listener "tcp" {
  address = "0.0.0.0:9202"
  purpose = "proxy"
}

# worker block for configuring the specifics of the
# worker service
worker {
  name              = "prd-worker"
  public_addr       = "boundary.dionathan.apps:32202"
  initial_upstreams = ["boundary.services.dionathan.apps:32201"]
  # auth_storage_path = "/boundary/auth_storage/"
  tags {
    env  = ["prd"]
    type = ["egress"]
  }
}

# Events (logging) configuration. This
# configures logging for ALL events to both
# stderr and a file at /var/log/boundary/<boundary_use>.log
events {
  audit_enabled       = true
  sysevents_enabled   = true
  observations_enable = true
  sink "stderr" {
    name = "all-events"
    description = "All events sent to stderr"
    event_types = ["*"]
    format = "cloudevents-json"
  }
  sink {
    name = "file-sink"
    description = "All events sent to a file"
    event_types = ["*"]
    format = "cloudevents-json"
    file {
      path = "/boundary/log/"
      file_name = "egress-worker.log"
    }
    audit_config {
      audit_filter_overrides {
        sensitive = "redact"
        secret    = "redact"
      }
    }
  }
}

kms "aead" {
  purpose = "worker-auth"
  aead_type = "aes-gcm"
  key = "cOQ9fiszFoxu/c20HbxRQ5E9dyDM6PqMY1GwqVLihsI="
  key_id = "global_worker-auth"
}

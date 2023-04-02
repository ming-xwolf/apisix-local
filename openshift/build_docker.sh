#!/usr/bin/env bash
set -e -u -o pipefail

declare -r SCRIPT_DIR=$(cd -P $(dirname $0) && pwd)

declare -r NAMESPACE=${NAMESPACE:-hello-openshift}

declare -r VERSION=${VERSION:-$(date +%s)}

declare -r NAME=${NAME:-nginx-proxy}


_log() {
    local level=$1; shift
    echo -e "$level: $@"
}

log.err() {
    _log "ERROR" "$@" >&2
}

info() {
    _log "\nINFO" "$@"
}

err() {
    local code=$1; shift
    local msg="$@"; shift
    log.err $msg
    exit $code
}

valid_command() {
  local fn=$1; shift
  [[ $(type -t "$fn") == "function" ]]
}

# helpers to avoid adding -n $NAMESPACE to oc and tkn
OC() {
  echo oc -n "$NAMESPACE" "$@"
  oc -n "$NAMESPACE" "$@"
}

TKN() {
 echo tkn -n "$NAMESPACE" "$@"
 tkn -n "$NAMESPACE" "$@"
}

demo.validate_tools() {
  info "validating tools"

  tkn version >/dev/null 2>&1 || err 1 "no tkn binary found"
  oc version  >/dev/null 2>&1 || err 1 "no oc binary found"
  return 0
}


bootstrap() {
    demo.validate_tools

    info "ensure namespace $NAMESPACE exists"
    OC get ns "$NAMESPACE" 2>/dev/null  || {
      OC new-project $NAMESPACE
    }
  }


demo.build() {
  info "build docker"
  podman build -t $NAME:$VERSION .

  info "oc login"
  OC login -u=developer

  info "login default openshift internal registry"
  podman login -u kubeadmin -p $(oc whoami -t) default-route-openshift-image-registry.apps-crc.testing --tls-verify=false

  info "tag local image"
  podman tag localhost/$NAME:$VERSION default-route-openshift-image-registry.apps-crc.testing/$NAMESPACE/$NAME:$VERSION

  info "push to internal registry"
  podman push default-route-openshift-image-registry.apps-crc.testing/$NAMESPACE/$NAME:$VERSION

}



demo.help() {
# NOTE: must insert leading TABS and not SPACE to align
  cat <<-EOF
		USAGE:
		  demo [command]

		COMMANDS:
		  build               starts pipeline to deploy api, ui
		  logs              shows logs of last pipelinerun
EOF
}

main() {
  local fn="demo.${1:-help}"
  valid_command "$fn" || {
    demo.help
    err  1 "invalid command '$1'"
  }

  cd "$SCRIPT_DIR"
  $fn "$@"
  return $?
}

main "$@"

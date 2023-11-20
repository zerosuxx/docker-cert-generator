#!/usr/bin/env bash
# version 0.1.1

#   ca.{crt,key}          Self signed CA certificate.
#   generic.{crt,key}     A certificate with no key usage/policy restrictions.
#   client.{crt,key}      A certificate restricted for SSL client usage.
#   server.{crt,key}      A certificate restricted for SSL server usage.

generate_cert() {
    local file_name="$1"
    local org_name="$2"
    local cn="$3"
    local opts="$4"

    local key_file=${file_name}.key
    local cert_file=${file_name}.crt

    openssl genrsa -out "$key_file" 2048
    openssl req \
        -new -sha256 \
        -subj "/O=$org_name/CN=$cn" \
        -key "$key_file" | \
        openssl x509 \
            -req -sha256 \
            -CA ca.crt \
            -CAkey ca.key \
            -CAserial ca.txt \
            -CAcreateserial \
            -days 365 \
            -out "$cert_file" \
            $opts
}

ORGANIZATION_NAME="$1"
COMMON_NAME="$2"
ALT_NAMES="$3"

if [ -z "$ORGANIZATION_NAME" ]; then
  echo "ORGANIZATION NAME: "
  read -r ORGANIZATION_NAME
fi

if [ -z "$COMMON_NAME" ]; then
  echo "COMMON NAME: "
  read -r COMMON_NAME
fi

if [ -z "$ALT_NAMES" ]; then
  echo "ALT_NAMES [eg: DNS.1=example.com,IP=192.168.1.1]: "
  read -r ALT_NAMES
fi

alt_names="${ALT_NAMES//,/
}"
CONF_DIR=$HOME

cat > "$CONF_DIR/openssl.cnf" <<EOF
[ server_cert ]
keyUsage = digitalSignature, keyEncipherment
nsCertType = server

[ client_cert ]
keyUsage = digitalSignature, keyEncipherment
nsCertType = client

[ san ]
subjectAltName=@alt_names

[alt_names]
DNS=$COMMON_NAME
$alt_names
EOF

openssl genrsa -out ca.key 4096
openssl req \
    -x509 \
    -new \
    -nodes \
    -sha256 \
    -key ca.key \
    -days 3650 \
    -subj "/O=$ORGANIZATION_NAME/CN=Certificate Authority" \
    -out ca.crt

generate_cert server "$ORGANIZATION_NAME" "${COMMON_NAME}" "-extfile $CONF_DIR/openssl.cnf -extensions server_cert"
generate_cert client "$ORGANIZATION_NAME" "${COMMON_NAME}" "-extfile $CONF_DIR/openssl.cnf -extensions client_cert"
generate_cert generic "$ORGANIZATION_NAME" "${COMMON_NAME}" "-extfile $CONF_DIR/openssl.cnf -extensions san"

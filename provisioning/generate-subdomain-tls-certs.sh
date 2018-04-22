#!/bin/bash

# ---------------------------------------------------------
# CUSTOMIZATION:

CSR_SUBJECT_C="EE"
CSR_SUBJECT_ST="Estonia"
CSR_SUBJECT_L="Tallinn"

# ---------------------------------------------------------
# VALIDATE CONSOLE ARGS
#
# PROG=$(basename "$0")
HERE=$(cd "$(dirname "$0")" && pwd)
# DOMAIN="${1}"

# if [ -z "$DOMAIN" ]; then
#     echo "Usage: ${PROG} <domain>"
#     exit 1
# fi
# ---------------------------------------------------------


function generate_subject () {
    declare -r target_domain="${1}"
    shift
    cat <<EOF
C=${CSR_SUBJECT_C}
ST=${CSR_SUBJECT_ST}
L=${CSR_SUBJECT_L}
O=${target_domain#*.}
CN=${target_domain}
OU=${target_domain#*.}
emailAddress=infosec@${target_domain#*.}
subjectAltName=DNS:${target_domain}
EOF
    echo
}

file_prefix="lets_encrypt"
private_key_filename="${file_prefix}.account.key"
public_key_filename="${private_key_filename}.pub"


declare -a DOMAINS


# DOMAINS+=( aes.partner.codes )
DOMAINS+=( api.partner.codes )
# DOMAINS+=( audio.partner.codes )
DOMAINS+=( blog.partner.codes )
# DOMAINS+=( box.partner.codes )
# DOMAINS+=( cdn.partner.codes )
# DOMAINS+=( chat.partner.codes )
# DOMAINS+=( cipher.partner.codes )
# DOMAINS+=( ciphertext.partner.codes )
# DOMAINS+=( cloud.partner.codes )
# DOMAINS+=( crypt0.partner.codes )
# DOMAINS+=( crypto.partner.codes )
# DOMAINS+=( data.partner.codes )
# DOMAINS+=( dist.partner.codes )
# DOMAINS+=( downloads.partner.codes )
# DOMAINS+=( drive.partner.codes )
# DOMAINS+=( drop.partner.codes )
# DOMAINS+=( dropbox.partner.codes )
# DOMAINS+=( email.partner.codes )
# DOMAINS+=( files.partner.codes )
# DOMAINS+=( github.partner.codes )
# DOMAINS+=( gnu.partner.codes )
# DOMAINS+=( gpg.partner.codes )
# DOMAINS+=( h4x0r.partner.codes )
# DOMAINS+=( info.partner.codes )
DOMAINS+=( io.partner.codes )
# DOMAINS+=( jabber.partner.codes )
DOMAINS+=( mail.partner.codes )
# DOMAINS+=( media.partner.codes )
# DOMAINS+=( onion.partner.codes )
# DOMAINS+=( opensource.partner.codes )
# DOMAINS+=( pgp.partner.codes )
# DOMAINS+=( pop.partner.codes )
DOMAINS+=( private.partner.codes )
# DOMAINS+=( projects.partner.codes )
# DOMAINS+=( public.partner.codes )
# DOMAINS+=( secure.partner.codes )
# DOMAINS+=( smtp.partner.codes )
# DOMAINS+=( static.partner.codes )
# DOMAINS+=( tor.partner.codes )
# DOMAINS+=( video.partner.codes )
# DOMAINS+=( voip.partner.codes )
# DOMAINS+=( web.partner.codes )
# DOMAINS+=( webrtc.partner.codes )
# DOMAINS+=( www.partner.codes )

DOMAINS+=( xmpp.partner.codes )

echo -e "\033[1;30mDOMAINS:\n${DOMAINS[*]}\033[0m" | tr '[:space:]' '\n'

function handle_error() {
    echo -ne "\033[0m"
    reason="${1}"
    shift
    echo -ne "\033[1;37mError: \033[0;31m${reason}\033[0m\n"
    echo -ne "\033[1;37musing password: \033[0;31m${reason}\033[0m\n"
    exit 1
}

function handle_success() {
    echo -ne "\033[0m"
    reason="${1}"
    shift
    echo -ne "\033[1;37mSuccess: \033[0;32m${reason}\033[0m\n"
}

function handle_info() {
    echo -ne "\033[0m"
    reason="${1}"
    shift
    echo -ne "\033[1;37mInfo: \033[0;34m${reason}\033[0m\n"
}

function handle_metadata() {
    echo -ne "\033[0m"
    reason="${1}"
    shift
    echo -ne "\033[0;33m${reason}\033[0m\n"
}


# generate private keys
if [ ! -f "${private_key_filename}" ]; then
    if openssl genrsa 4096 > "${private_key_filename}"; then
        cp -v $private_key_filename user.key
        handle_success "generated key: ${private_key_filename}"
    else
        handle_error "failed to generate private key: ${private_key_filename}"
    fi
fi


if [ ! -f "${public_key_filename}" ]; then
    # derive public key
    if openssl rsa -in "${private_key_filename}" -pubout > "${public_key_filename}"; then
        handle_success "derived public key: ${public_key_filename} from ${private_key_filename}"
    else
        handle_error "failed to derive public key: ${public_key_filename} from ${private_key_filename}"
    fi
fi

for current in ${DOMAINS[*]}; do
    domain_private_key_filename="${file_prefix}.${current}.key"

    csr_filename="${file_prefix}.${current}.csr"
    cert_filename="${file_prefix}.${current}.cert"

    if [ ! -f "${domain_private_key_filename}" ]; then
        if openssl genrsa 4096 > "${domain_private_key_filename}"; then
            handle_success "generated key: ${domain_private_key_filename}"
        else
            handle_error "failed to generate private key: ${domain_private_key_filename}"
        fi
    fi

    EMAIL="infosec@${current#*.}"
    CSRSBJCT="$(generate_subject "${current}" | tr "\n" "/")"
    echo -e "\033[1;30mCSR Subject:\n${CSRSBJCT}\033[0m" | tr '[:space:]' '\n'

    if [ ! -f "${csr_filename}" ]; then
        # Generate the CSR
        if openssl req \
                   -new \
                   -batch \
                   -subj "/${CSRSBJCT%%/}" \
                   -key "${domain_private_key_filename}" \
                   -out "${csr_filename}" ; then
            handle_success "generated self-signed certificate request: ${csr_filename} with key ${domain_private_key_filename}"
        else
            handle_error "failed to generate self-signed certificate request: ${csr_filename} with key ${domain_private_key_filename}"
        fi
    fi
    # Generate the cert with letsencrypt
    if [ ! -f "${cert_filename}" ]; then
        if python "${HERE}/sign_csr.py" --email="${EMAIL}" --public-key "${public_key_filename}" "${csr_filename}" > "${cert_filename}"; then
            handle_success "Generated Let's Encrypt Certificate"
        else
            handle_error "Failed to sign CSR with Let's Encrypt"
        fi
    fi
done

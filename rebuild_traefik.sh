#!/bin/bash
STACK_NAME=RSHB_dev
SERVICES=(traefik ipsisoservice cryptoservice)
COMPOSE_FILE=deploy_ipsiso.yml

SECRETS=(
    "rshb_dev_iso-config-11a13033bf4cgf1d72a32a229b777"
    "rshb_dev_iso-hosting-11d11033df8cfa6d84f29a11cb2a04"
    "rshb_dev_iso-key-11d11033df8cbf6d84f39a118b2a06"
    "rshb_dev_iso-key-11d11033df8cbf8d84f38a128c2a25"
    "rsgb_ca_bundle-11d11033df8cbf8d8312354532123dsda8a129c2a19"
    "rshb_ipsadapter_pfx-11d11033df8cbf8d84f38a128c2a14"
    "SBP_tst-ekcrypto001_000000000330000043"
    "rshb_dev_iso-adapter-fc9e157ad5664906f1f16411776db54d"
    "SBP_dev_appconfig-app_sec_placeholder1235670402256794477"
    "SBP_tst-ekcrypto001_000002002030050003"
    "SBP_tst-hosting001_000012345808800990124"
    "SBP_dev_cert-toml_00000000000000009"
    "SBP_dev_cert-iso-cer_00000000000000003"
    "SBP_dev_cert-iso-key_00000000000000002"
    "SBP_dev_binding_cert_00000000000000008"
    "SBP_dev_binding_key_00000000000000008"
    "SBP_dev_binding_ca_00000000000000008"
)

echo "Удаляем сервисы:"
for service in "${SERVICES[@]}"; do
    for svc in $(docker service ls --quiet --filter "NAME="${STACK_NAME}_${service}); do
            docker service rm "$svc"
    done
done

echo ""

echo "Удаляем сикреты:"
for secret in "${SECRETS[@]}"; do
    if docker secret ls --quiet --filter "name=${secret}" | grep -q .; then
        docker secret rm "$secret"
    fi
done


echo ""

echo "Deploy'им сервисы:"
for deploy in "${COMPOSE_FILE[@]}"; do
    docker stack deploy --with-registry-auth -c $deploy $STACK_NAME
done

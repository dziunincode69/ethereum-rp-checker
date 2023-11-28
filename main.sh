#!/bin/bash
FILE="url.txt"

check_rpc() {
    local ip_port=$1
    local url="http://$ip_port"

    local version_response=$(curl --silent --fail "$url" -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}')

    if [[ -n $version_response ]]; then
        local web3_version=$(echo $version_response | jq -r '.result')

        local sync_response=$(curl --silent "$url" -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}')
        local is_synced=$(echo $sync_response | jq -r '.result == false')

        local block_response=$(curl --silent "$url" -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}')
        local block_number=$(echo $block_response | jq -r '.result')

        if [[ $is_synced == "true" ]]; then
            echo "$ip_port LIVE and Synced - Web3 Client Version: $web3_version, Block Number: $block_number"
        else
            echo "$ip_port LIVE but not Synced - Web3 Client Version: $web3_version, Block Number: $block_number"
        fi
    else
        echo "$ip_port DEAD"
    fi
}

while IFS= read -r ip_port
do
    check_rpc "$ip_port" &
done < "$FILE"


wait

#Atelier_Ethereum_10mars2016 

## lancer testnet
testrpc

## lancer serveur truffle (dans rep de l'app)
truffle serve

## commandes examples

### liste des comptes
web3.eth.accounts

### current block
web3.eth.blockNumber
=> 0

### send ether
web3.eth.sendTransaction({from: web3.eth.coinbase, to: web3.eth.accounts[1], value : web3.toWei(50, 'ether')})
=> "0x37e64c314fec21e0a14ca07847d39470020194ec43b2ee811499630bb41239dd"
web3.eth.blockNumber
=> 1
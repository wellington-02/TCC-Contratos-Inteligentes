# TCC-Contratos-Inteligentes
Esses são todos os repositórios oficiais de cada protocolo DeFi utilizados na contrução do TCC. É importante frizar que este repositório será mantido apenas para fins de reprodução dos resultados apresentados no artigo.

## Instuções para realizar a análise estática usando o Slither:
Usando o repositório core (Lido) como exemplo.
* 1 - Acesse a pasta do contrado desejado: cd core
* 2 - Execute o comando para acessar a venv: source venv/bin/activate
* 3 - Esse contrato utiliza o hardhat, execute: npm i
* 4 - Faça a compilação: npx hardhat compile
* 5 - Execute o slither filtrando o contrado desejado: slither . --compile-force-framework hardhat --filter-paths "contracts/0\.4\.24/Lido\.sol"

* obs: comando para instalar o slither, caso exija: pip install slither-analyzer

## Instuções para realizar a análise estática usando o Mythril:
Usando o repositório core (Lido) como exemplo.
* 1 - Acesse a pasta do contrado desejado: cd core
* 2 - Execute o comando para acessar a venv: source venv/bin/activate
* 3 - Esse contrato utiliza o hardhat, execute: npm i
* 4 - Faça a compilação: npx hardhat compile
* 5 - Obtenha um arquivo com o runtime bytecode limpo, pronto para análise simbólica: jq -r '.deployedBytecode | sub("^0x"; "")' \
  artifacts/contracts/0.4.24/Lido.sol/Lido.json > /tmp/Lido-runtime.hex
* 6 - Obtenha um arquivo com o creation bytecode, usado para analisar a lógica do constructor:
  jq -r '.bytecode | sub("^0x"; "")' \
  artifacts/contracts/0.4.24/Lido.sol/Lido.json > /tmp/Lido-create.hex
* 7 - Execute o mythril: myth analyze -f /tmp/Lido-runtime.hex -t 3 --execution-timeout 900 -o text

* obs: comando para instalar o mythril, caso exija: pip install mythril

## Instuções para realizar a análise estática em repositórios que utilizam o foundry:
* 1 - Acesse a pasta do contrado desejado: cd nome do repositório
* 2 - Execute o comando para acessar a venv: source venv/bin/activate
* 3 - Instale o foundry: forge install
* 4 - Caso precise, intale o OpenZeppelin: forge install OpenZeppelin/openzeppelin-contracts
* 5 - Caso queira fazer a análise utilizando o slither: slither caminho/nome do arquivo.sol
* 6 - Caso queira fazer a análise utilizando o mythril: myth analyze caminho/nome do arquivo.sol

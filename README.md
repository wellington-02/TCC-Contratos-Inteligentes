# TCC-Contratos-Inteligentes
Esses são todos os repositórios oficiais de cada protocolo Defi utilizados na contrução do TCC. É importante frizar que este repositório será mantido apenas pelo fim de reprodução dos resultados apresentados no artigo.

## Instuções para realizar a análise estática usando o Slither:
* 1 - Acesse a pasta do contrado desejado: cd nome da pasta
* 2 - Execute o comando para de acessar a venv: source venv/bin/activate
* 3 - Caso o projeto utiliza o foundry, execute: forge install
* 4 - Em alguns casos será necessário utilizar instalar o openZeppelin: forge install OpenZeppelin/openzeppelin-contracts
* 5 - Execute o slither no contrato desejado: slither cominho/arquivo.sol (ex: slither contracts/contracts/EthenaMinting.sol)

* obs: comando para instalar o slither, caso exija: pip install slither-analyzer

## Instuções para realizar a análise estática usando o Mythril:
* 1 - Acesse a pasta do contrado desejado: cd nome da pasta
* 2 - Execute o comando para de acessar a venv: source venv/bin/activate
* 3 - Caso o projeto utiliza o foundry, execute: forge install
* 4 - Em alguns casos será necessário utilizar instalar o openZeppelin: forge install OpenZeppelin/openzeppelin-contracts
* 5 - Execute o slither no contrato desejado: mythril analyze cominho/arquivo.sol (ex: slither contracts/contracts/EthenaMinting.sol)

* obs: comando para instalar o mythril, caso exija: pip install mythril

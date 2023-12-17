#!/bin/bash

# Verifica se o jq está instalado
if ! command -v jq &> /dev/null; then
    echo "jq não encontrado. Instalando..."
    sudo apt-get update
    sudo apt-get install -y jq

    if ! command -v jq &> /dev/null; then
        echo "Não foi possível instalar o jq. Por favor, instale manualmente e tente novamente."
        exit 1
    fi
fi

# Função para baixar o arquivo JSON
baixar_index_json() {
    wget -q -O index.json https://chaos-data.projectdiscovery.io/index.json
}

# Verifica se o arquivo JSON está presente e possui conteúdo
if [ ! -s "index.json" ]; then
    echo "Baixando o arquivo index.json..."
    baixar_index_json

    if [ ! -s "index.json" ]; then
        echo "Erro ao baixar o arquivo index.json. Verifique sua conexão de internet ou tente novamente mais tarde."
        exit 1
    fi
fi

echo "Arquivo index.json encontrado."
echo "Conteúdo do arquivo:"
cat index.json >/dev/null 2>&1

# Processamento do arquivo JSON
platforms_bugcrowd=($(jq -r '.[] | select((.platform == "bugcrowd") and (.bounty == true)) | .URL' index.json))
platforms_hackerone=($(jq -r '.[] | select((.platform == "hackerone") and (.bounty == true)) | .URL' index.json))
platforms_yeswehack=($(jq -r '.[] | select((.platform == "yeswehack") and (.bounty == true)) | .URL' index.json))
platforms_private=($(jq -r '.[] | select((.platform == "") and (.bounty == true)) | .URL' index.json))
platforms_nobounty=($(jq -r '.[] | select((.bounty == false)) | .URL' index.json))

# Criação das pastas e download dos arquivos
mkdir -p bugcrowd hackerone yeswehack private nobounty

cd bugcrowd || exit
for url in "${platforms_bugcrowd[@]}"; do
    wget "$url"
done
cd ..

cd hackerone || exit
for url in "${platforms_hackerone[@]}"; do
    wget "$url"
done
cd ..

cd yeswehack || exit
for url in "${platforms_yeswehack[@]}"; do
    wget "$url"
done
cd ..

cd private || exit
for url in "${platforms_private[@]}"; do
    wget "$url"
done
cd ..

cd nobounty || exit
for url in "${platforms_nobounty[@]}"; do
    wget "$url"
done
cd ..

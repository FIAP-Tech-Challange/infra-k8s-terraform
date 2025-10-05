#!/bin/bash

# Script para executar todos os testes do projeto de infraestrutura
# Execute: ./run-tests.sh

set -e  # Parar em caso de erro

echo "🚀 Iniciando testes da infraestrutura..."
echo "==========================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir com cores
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar se estamos no diretório correto
if [[ ! -f "main.tf" ]] || [[ ! -d "modules" ]]; then
    print_error "Execute este script no diretório raiz do projeto (onde está o main.tf)"
    exit 1
fi

# 1. Testes do Node.js (Authorizer)
print_status "Executando testes do Gateway Authorizer..."
cd modules/gateway/authorizer

if [[ ! -f "package.json" ]]; then
    print_error "package.json não encontrado no diretório modules/gateway/authorizer"
    exit 1
fi

# Verificar se node_modules existe
if [[ ! -d "node_modules" ]]; then
    print_warning "node_modules não encontrado. Instalando dependências..."
    npm install
fi

# Executar testes
print_status "Executando testes unitários..."
npm test

print_status "Executando testes com cobertura..."
npm run test:coverage

print_success "Testes do Node.js concluídos com sucesso!"

# Voltar para o diretório raiz
cd ../../..

# 2. Validação do Terraform
print_status "Validando arquivos Terraform..."

# Verificar se terraform está instalado
if ! command -v terraform &> /dev/null; then
    print_warning "Terraform não está instalado. Pulando validação Terraform."
else
    # Validar formatação
    print_status "Verificando formatação do Terraform..."
    if terraform fmt -check -recursive; then
        print_success "Formatação do Terraform está correta"
    else
        print_warning "Alguns arquivos Terraform não estão formatados corretamente"
        print_status "Execute 'terraform fmt -recursive' para corrigir"
    fi
    
    # Validar main
    print_status "Validando Terraform principal..."
    terraform init -backend=false > /dev/null 2>&1 || true
    if terraform validate; then
        print_success "Terraform principal válido"
    else
        print_error "Terraform principal inválido"
        exit 1
    fi
    
    # Validar gateway
    print_status "Validando Gateway Terraform..."
    cd modules/gateway
    terraform init -backend=false > /dev/null 2>&1 || true
    if terraform validate; then
        print_success "Gateway Terraform válido"
    else
        print_error "Gateway Terraform inválido"
        cd ..
        exit 1
    fi
    cd ..
    
    # Validar authorizer IAC
    print_status "Validando Authorizer IAC..."
    cd modules/gateway/authorizer/iac
    terraform init -backend=false > /dev/null 2>&1 || true
    if terraform validate; then
        print_success "Authorizer IAC válido"
    else
        print_error "Authorizer IAC inválido"
        cd ../../../..
        exit 1
    fi
    cd ../../../..
fi

# 3. Verificações adicionais
print_status "Executando verificações adicionais..."

# Verificar se existem arquivos de teste
test_files=$(find . -name "*.test.js" -o -name "*.spec.js" | wc -l)
print_status "Encontrados $test_files arquivos de teste"

# Verificar cobertura
if [[ -f "modules/gateway/authorizer/coverage/lcov-report/index.html" ]]; then
    print_success "Relatório de cobertura gerado em: modules/gateway/authorizer/coverage/lcov-report/index.html"
fi

# Relatório final
echo ""
echo "==========================================="
print_success "🎉 Todos os testes foram executados com sucesso!"
echo ""
print_status "Resumo:"
print_status "  ✅ Testes unitários do Authorizer"
print_status "  ✅ Cobertura de código gerada"
if command -v terraform &> /dev/null; then
    print_status "  ✅ Validação Terraform"
else
    print_warning "  ⚠️  Terraform não instalado (validação pulada)"
fi

echo ""
print_status "Para ver o relatório de cobertura, abra:"
print_status "  modules/gateway/authorizer/coverage/lcov-report/index.html"
echo "==========================================="

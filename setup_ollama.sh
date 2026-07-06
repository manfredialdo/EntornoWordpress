#!/bin/bash

# Nombre del modelo que vamos a usar
MODEL_NAME="llama3.2:1b"

echo "=== 🤖 Iniciando Autoconfiguración de Ollama en Codespaces ==="

# ---------------------------------------------------------
# PASO 0: Verificar e Instalar Dependencias Obligatorias (zstd)
# ---------------------------------------------------------
if command -v zstd &> /dev/null; then
    echo "✔ La dependencia 'zstd' ya está instalada."
else
    echo "⏳ 'zstd' no detectado. Instalándolo para poder extraer Ollama..."
    sudo apt-get update && sudo apt-get install -y zstd
    if [ $? -eq 0 ]; then
        echo "✔ 'zstd' instalado correctamente."
    else
        echo "❌ Error al instalar 'zstd'. Verifica tus permisos de sudo."
        exit 1
    fi
fi

# ---------------------------------------------------------
# PASO 1: Verificar e Instalar Ollama
# ---------------------------------------------------------
if command -v ollama &> /dev/null; then
    echo "✔ Ollama ya está instalado. Omitiendo instalación."
else
    echo "⏳ Ollama no detectado. Instalando..."
    curl -fsSL https://ollama.com/install.sh | sh
    if [ $? -eq 0 ]; then
        echo "✔ Ollama instalado correctamente."
    else
        echo "❌ Error al instalar Ollama."
        exit 1
    fi
fi

# ---------------------------------------------------------
# PASO 2: Verificar e Iniciar el Servidor (ollama serve)
# ---------------------------------------------------------
if lsof -i :11434 &> /dev/null || curl -s http://localhost:11434 &> /dev/null; then
    echo "✔ El servidor de Ollama ya está corriendo y activo."
else
    echo "⏳ Iniciando el servidor de Ollama en segundo plano..."
    ollama serve > ollama.log 2>&1 &
    
    echo "⏳ Esperando a que el servicio responda en el puerto 11434..."
    for i in {1..15}; do
        if curl -s http://localhost:11434 &> /dev/null; then
            echo "✔ Servidor de Ollama conectado exitosamente."
            break
        fi
        sleep 1
        if [ $i -eq 15 ]; then
            echo "❌ El servidor de Ollama tardó demasiado en responder. Revisa 'ollama.log'."
            exit 1
        fi
    done
fi

# ---------------------------------------------------------
# PASO 3: Verificar y Descargar el Modelo
# ---------------------------------------------------------
echo "⏳ Verificando si el modelo '$MODEL_NAME' ya existe localmente..."
if ollama list | grep -q "$MODEL_NAME"; then
    echo "✔ El modelo '$MODEL_NAME' ya está descargado y listo para usar."
else
    echo "⏳ Descargando el modelo '$MODEL_NAME' (esto puede demorar un par de minutos)..."
    ollama pull "$MODEL_NAME"
    if [ $? -eq 0 ]; then
        echo "✔ Modelo '$MODEL_NAME' descargado con éxito."
    else
        echo "❌ Error al descargar el modelo."
        exit 1
    fi
fi

echo "========================================================="
echo "🎉 ¡Todo listo! Tu entorno de IA está corriendo al 100%."
echo "Puedes interactuar en la terminal usando: ollama run $MODEL_NAME"
echo "O pegarle a la API local en: http://localhost:11434/api/generate"
echo "========================================================="
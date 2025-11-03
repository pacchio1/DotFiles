#!/bin/bash

# Script per attivare/disattivare i moduli KVM (kvm_amd e kvm)

MODULO_AMD="kvm_amd"
MODULO_KVM="kvm"
MODULO_INTEL="kvm_intel" # Aggiunto per coerenza con la logica di caricamento

# Funzione per verificare se un modulo è caricato
# Cerca il nome esatto del modulo nell'output di lsmod
is_loaded() {
  lsmod | grep -E "^$1 " >/dev/null
}

# --- LOGICA DEL TOGGLE ---

if is_loaded "$MODULO_KVM"; then
  echo "I moduli KVM (kvm, kvm_amd/intel) sono caricati. Scaricamento in corso..."

  # Tentativo di scaricare prima kvm_amd e poi kvm
  # Utilizziamo sudo per i comandi modprobe -r

  # 1. Scarica il modulo specifico del processore (AMD o Intel)
  if is_loaded "$MODULO_AMD"; then
    sudo modprobe -r "$MODULO_AMD" 2>/dev/null
    echo "Tentativo di scaricare $MODULO_AMD."
  elif is_loaded "$MODULO_INTEL"; then
    sudo modprobe -r "$MODULO_INTEL" 2>/dev/null
    echo "Tentativo di scaricare $MODULO_INTEL."
  fi

  # 2. Scarica il modulo KVM principale
  if sudo modprobe -r "$MODULO_KVM"; then
    echo "Modulo $MODULO_KVM scaricato con successo."
  else
    echo "ERRORE: Impossibile scaricare il modulo $MODULO_KVM. Assicurati che non ci siano macchine virtuali in esecuzione."
    exit 1
  fi

# Se kvm non è caricato (stato disattivato)
else
  echo "I moduli KVM non sono caricati. Caricamento in corso..."

  # 1. Carica il modulo specifico del processore
  # Diamo priorità a kvm_amd come richiesto, ma includiamo il fallback per Intel.
  if sudo modprobe "$MODULO_AMD" 2>/dev/null; then
    echo "Modulo $MODULO_AMD caricato."
  elif [ -f "/lib/modules/$(uname -r)/kernel/arch/x86/kvm/kvm_intel.ko" ]; then
    # Se kvm_amd fallisce, proviamo kvm_intel
    echo "Modulo $MODULO_AMD non presente o non caricabile. Tentativo con kvm_intel..."
    if sudo modprobe "$MODULO_INTEL"; then
      echo "Modulo $MODULO_INTEL caricato."
    else
      echo "ATTENZIONE: Impossibile caricare $MODULO_INTEL."
    fi
  else
    echo "ATTENZIONE: Né $MODULO_AMD né $MODULO_INTEL sono stati caricati (potrebbe essere un sistema non-x86 o con virtualizzazione disabilitata)."
  fi

  # 2. Carica il modulo kvm principale
  if sudo modprobe "$MODULO_KVM"; then
    echo "Modulo $MODULO_KVM caricato con successo."
  else
    echo "ERRORE: Impossibile caricare il modulo $MODULO_KVM."
    exit 1
  fi
fi

# Visualizza lo stato finale
echo ""
echo "Stato attuale dei moduli KVM:"
lsmod | grep "$MODULO_KVM"
lsmod | grep "$MODULO_AMD"
lsmod | grep "$MODULO_INTEL"

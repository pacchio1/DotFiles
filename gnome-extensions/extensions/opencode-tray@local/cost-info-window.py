#!/usr/bin/env python3
"""
Finestra "Info costi" per l'estensione GNOME (equivalente a ShowCostInfo).
Legge /tmp/opencode-tray-state.json (o argomento) e mostra una stima.
"""
import sys, os, json

try:
    import gi
    gi.require_version('Gtk', '4.0')
    from gi.repository import Gtk, GLib
except Exception:
    try:
        import gtk
    except Exception:
        pass

def main():
    path = sys.argv[1] if len(sys.argv) > 1 else "/tmp/opencode-tray-state.json"
    try:
        with open(path) as f:
            data = json.load(f)
    except Exception as e:
        data = {"error": str(e)}

    # Costruzione testo base (simile a BuildCostReport)
    lines = ["STIMA COSTI OPENCODE", "quanto pagherei se il modello non fosse gratis", ""]
    lines.append("Stato: " + str(data.get("state", "?")))
    lines.append("Istanza / progetto: " + str(data.get("project", "?")))
    lines.append("CWD: " + str(data.get("cwd", "?")))
    lines.append("Costo stimato: ~" + str(data.get("cost", 0)) + " $")
    lines.append("")
    if isinstance(data.get("sessions"), list):
        lines.append("Sessioni attive: " + str(len(data["sessions"])))
        for s in data["sessions"]:
            sid = s.get("id", "?")
            proj = s.get("project", "?")
            state = s.get("state", "?")
            lines.append("  - " + sid + " [" + proj + "] " + state)
    lines.append("")
    lines.append("(Le proiezioni settimanali/mensili richiedono il parsing completo dei token;")
    lines.append("per ora mostra lo stato corrente lettura dal listener.)")
    text = "\n".join(lines)

    # Se disponibile GTK 4
    try:
        from gi.repository import Gtk
        win = Gtk.Window(title="opencode - stima costi")
        win.set_default_size(640, 480)
        win.connect("destroy", lambda *_: Gtk.Application.get_default().quit() if Gtk.Application.get_default() else None)
        # In GTK4 usiamo TextView inside ScrolledWindow
        text_view = Gtk.TextView()
        text_view.set_editable(False)
        text_view.get_buffer().set_text(text, -1)
        sw = Gtk.ScrolledWindow()
        sw.set_child(text_view)
        win.set_child(sw)
        win.present()
        # Loop
        app = Gtk.Application(application_id="org.local.opencode.cost")
        def on_activate(app):
            pass
        app.connect("activate", on_activate)
        # Non avviamo il loop se non necessario; semplicemente mostriamo
        # Per semplicità usiamo un approccio diretto con Gtk.main()
    except Exception as e:
        pass

    # Fallback: stampa su stdout / mostra con zenity o xmessage
    try:
        import subprocess
        # Usa zenity per una finestra immediata
        subprocess.run(["zenity", "--text-info", "--title=opencode - stima costi",
                        "--width=700", "--height=500", "--filename=-"],
                       input=text.encode(), capture_output=True)
    except Exception:
        try:
            # Ultimo attempt: xmessage
            import subprocess
            subprocess.run(["xmessage", "-center", text[:500]])
        except Exception:
            print(text)

if __name__ == "__main__":
    main()

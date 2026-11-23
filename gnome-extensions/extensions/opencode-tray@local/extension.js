/* opencode-tray - GNOME Shell 45+ extension
 *
 * Bridge: plugin opencode-tray.js -> HTTP POST 127.0.0.1:47110
 *         -> listener python -> /tmp/opencode-tray-state.json
 *         -> questa estensione legge il file ogni 2s.
 *
 * Stati: idle (grigio/nero) / working (verde) / attention (giallo).
 */

import GObject from 'gi://GObject';
import St from 'gi://St';
import GLib from 'gi://GLib';
import Gio from 'gi://Gio';

import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';
import * as PopupMenu from 'resource:///org/gnome/shell/ui/popupMenu.js';

import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

const STATE_FILE = '/tmp/opencode-tray-state.json';
const SETTINGS_DIR = GLib.get_home_dir() + '/.config/opencode-tray';
const SETTINGS_FILE = SETTINGS_DIR + '/settings.json';
const DEFAULT_HEARTBEAT_SEC = 25;

// Posizione nel pannello di destra: 4 = quarta icona partendo da sinistra.
const PANEL_INDEX = 4;

// Posizionamenti offerti dal menu (sezione + indice).
const POSITIONS = {
    left: {section: 'right', index: 0},
    center: {section: 'center', index: 0},
    right: {section: 'right', index: PANEL_INDEX},
};

let _decoder = null;
function decode(bytes) {
    if (_decoder === null)
        _decoder = new TextDecoder('utf-8');
    if (bytes instanceof Uint8Array)
        return _decoder.decode(bytes);
    // GLib.Bytes (vecchie versioni)
    return _decoder.decode(bytes.get_data());
}

function readJson(path) {
    try {
        const file = Gio.File.new_for_path(path);
        if (!file.query_exists(null))
            return null;
        const [ok, contents] = file.load_contents(null);
        if (!ok || !contents)
            return null;
        return JSON.parse(decode(contents));
    } catch (_e) {
        return null;
    }
}

function ensureDir(path) {
    try {
        const dir = Gio.File.new_for_path(path);
        if (!dir.query_exists(null))
            dir.make_directory_with_parents(null);
    } catch (_e) {}
}

function writeJson(path, obj) {
    try {
        ensureDir(path.substring(0, path.lastIndexOf('/')));
        const file = Gio.File.new_for_path(path);
        file.replace_contents(
            JSON.stringify(obj, null, 2),
            null, false,
            Gio.FileCreateFlags.REPLACE_DESTINATION,
            null);
    } catch (_e) {}
}

function openFolder(path) {
    try {
        Gio.AppInfo.launch_default_for_uri(
            Gio.File.new_for_path(path).get_uri(), null);
    } catch (_e) {}
}

function stateLabel(state) {
    if (state === 'working')
        return 'lavorando';
    if (state === 'attention')
        return 'attenzione';
    return 'inattivo';
}

// Una riga per sessione, inviata dal plugin:
// sid|project|cwd|state|reason|activity|cost24|cost7|firstAt|models
function parseSessions(raw) {
    const out = [];
    if (Array.isArray(raw)) {
        for (const s of raw) {
            if (s && typeof s === 'object') {
                out.push({
                    id: String(s.id ?? ''),
                    project: String(s.project ?? '?'),
                    state: String(s.state ?? 'idle'),
                    reason: String(s.reason ?? ''),
                    activity: String(s.activity ?? ''),
                });
            }
        }
        return out;
    }
    if (typeof raw === 'string') {
        for (const line of raw.split('\n')) {
            if (!line.trim())
                continue;
            const p = line.split('|');
            out.push({
                id: p[0] ?? '',
                project: p[1] || '?',
                state: p[3] || 'idle',
                reason: p[4] ?? '',
                activity: p[5] ?? '',
            });
        }
    }
    return out;
}

const Indicator = GObject.registerClass(
class OpencodeTrayIndicator extends PanelMenu.Button {
    _init(extension) {
        super._init(0.0, 'opencode-tray', false);
        this._ext = extension;

        this._state = 'idle';
        this._live = 0;
        this._cost = 0.0;
        this._sessions = [];
        this._flashId = 0;
        this._pulseOn = false;

        // Icona nel pannello: SVG colorato, sempre visibile
        this._icon = new St.Icon({
            gicon: Gio.icon_new_for_string(
                this._ext.path + '/assets/icon-idle.svg'),
            style_class: 'system-status-icon opencode-tray-icon',
        });
        this.add_child(this._icon);

        // --- menu ---
        this._statusItem = new PopupMenu.PopupMenuItem('stato: inattivo', {reactive: false});
        this.menu.addMenuItem(this._statusItem);

        this._costItem = new PopupMenu.PopupMenuItem('opencode: ca. 0.00 $', {reactive: false});
        this.menu.addMenuItem(this._costItem);

        this._projectsItem = new PopupMenu.PopupSubMenuMenuItem('Istanze opencode');
        this.menu.addMenuItem(this._projectsItem);

        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());

        this._resetItem = new PopupMenu.PopupMenuItem('Azzera conteggio costi');
        this._resetItem.connect('activate', () => this._onReset());
        this.menu.addMenuItem(this._resetItem);

        this._infoItem = new PopupMenu.PopupMenuItem('Info costi (modello - token)');
        this._infoItem.connect('activate', () => this._onInfo());
        this.menu.addMenuItem(this._infoItem);

        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());

        this._posItem = new PopupMenu.PopupSubMenuMenuItem('Posizione nel pannello');
        this._posItems = {};
        const posLabels = {
            left: 'Sinistra',
            center: "Centro (accanto all'orologio)",
            right: 'Destra',
        };
        for (const key of ['left', 'center', 'right']) {
            const it = new PopupMenu.PopupMenuItem(posLabels[key]);
            it.connect('activate', () => this._moveTo(key));
            this._posItems[key] = it;
            this._posItem.menu.addMenuItem(it);
        }
        this.menu.addMenuItem(this._posItem);
        this._refreshPosition();

        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());

        const s = readJson(SETTINGS_FILE) ?? {};

        this._balloonItem = new PopupMenu.PopupSwitchMenuItem(
            'Popup di notifica', !!s.balloon);
        this._balloonItem.connect('toggled', (_i, v) => this._setOpt('balloon', v));
        this.menu.addMenuItem(this._balloonItem);

        this._soundItem = new PopupMenu.PopupSwitchMenuItem(
            'Suono di avviso', !!s.sound);
        this._soundItem.connect('toggled', (_i, v) => this._setOpt('sound', v));
        this.menu.addMenuItem(this._soundItem);

        this._flashItem = new PopupMenu.PopupSwitchMenuItem(
            'Icona lampeggiante in attesa', !!s.flash);
        this._flashItem.connect('toggled', (_i, v) => this._setOpt('flash', v));
        this.menu.addMenuItem(this._flashItem);

        this._autostartItem = new PopupMenu.PopupSwitchMenuItem(
            'Avvia con la sessione', !!s.startWithSession);
        this._autostartItem.connect('toggled', (_i, v) => this._setOpt('startWithSession', v));
        this.menu.addMenuItem(this._autostartItem);

        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());

        this._cfgItem = new PopupMenu.PopupMenuItem('Apri configurazione opencode');
        this._cfgItem.connect('activate', () =>
            openFolder(GLib.get_home_dir() + '/.config/opencode'));
        this.menu.addMenuItem(this._cfgItem);

        this._instItem = new PopupMenu.PopupMenuItem('Apri cartella estensione');
        this._instItem.connect('activate', () => openFolder(this._ext.path));
        this.menu.addMenuItem(this._instItem);

        this._logItem = new PopupMenu.PopupMenuItem('Apri configurazione tray');
        this._logItem.connect('activate', () => openFolder(SETTINGS_DIR));
        this.menu.addMenuItem(this._logItem);

        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());

        this._exitItem = new PopupMenu.PopupMenuItem('Esci');
        this._exitItem.connect('activate', () => {
            if (this._ext) {
                try {
                    this._ext.disable();
                } catch (_e) {}
            }
        });
        this.menu.addMenuItem(this._exitItem);

        this._applyState();
        this._poll();
        this._pollId = GLib.timeout_add_seconds(
            GLib.PRIORITY_DEFAULT, 2, () => {
                this._poll();
                return GLib.SOURCE_CONTINUE;
            });
    }

    _refreshPosition() {
        const pos = readJson(SETTINGS_FILE)?.position ?? 'right';
        for (const [key, item] of Object.entries(this._posItems))
            item.setOrnament(pos === key
                ? PopupMenu.Ornament.CHECK
                : PopupMenu.Ornament.NONE);
    }

    _moveTo(key) {
        const cfg = POSITIONS[key] ?? POSITIONS.right;
        const s = readJson(SETTINGS_FILE) ?? {};
        s.position = key;
        // indice configurabile anche su sinistra (default da POSITIONS)
        if (s.index !== undefined && s.index !== null) {
            cfg.index = Number(s.index);
        }
        writeJson(SETTINGS_FILE, s);
        this._ext.reposition(cfg.section, cfg.index);
        this._refreshPosition();
    }

    _setOpt(key, value) {
        const s = readJson(SETTINGS_FILE) ?? {};
        s[key] = !!value;
        writeJson(SETTINGS_FILE, s);
    }

    _onReset() {
        ensureDir(SETTINGS_DIR);
        writeJson(SETTINGS_DIR + '/cost-base.json', {
            resetAt: Date.now(),
            version: 1,
        });
    }

    _onInfo() {
        try {
            GLib.spawn_command_line_async(
                `python3 "${this._ext.path}/cost-info-window.py" "${STATE_FILE}"`);
        } catch (_e) {}
    }

    _poll() {
        const d = readJson(STATE_FILE);
        if (!d)
            return;

        let state = String(d.state ?? 'idle').toLowerCase();
        if (!['idle', 'working', 'attention'].includes(state))
            state = 'idle';

        // heartbeat: se il file è vecchio, opencode non c'è più
        const hb = (readJson(SETTINGS_FILE)?.heartbeatTimeoutSec) ||
                   DEFAULT_HEARTBEAT_SEC;
        const ts = Number(d.ts ?? 0);
        if (ts > 0 && (Date.now() - ts) > hb * 1000) {
            state = 'idle';
        }

        this._sessions = parseSessions(d.sessions);
        this._live = this._sessions.length;
        this._cost = Number(d.cost ?? 0) || 0;

        if (state !== this._state) {
            this._state = state;
            this._applyState();
        }
        this._refreshMenu();
    }

    _applyState() {
        let file = 'icon-idle';
        if (this._state === 'working')
            file = 'icon-working';
        else if (this._state === 'attention')
            file = 'icon-attention';

        this._icon.gicon = Gio.icon_new_for_string(
            `${this._ext.path}/assets/${file}.svg`);

        this._stopFlash();
        // lampeggio disattivato: colore fisso (come richiesto)
        // if (this._state === 'attention' &&
        //     (readJson(SETTINGS_FILE)?.flash))
        //     this._startFlash();
    }

    _startFlash() {
        let on = true;
        this._pulseOn = false;
        this._flashId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 500, () => {
            on = !on;
            this._icon.opacity = on ? 255 : 60;
            return GLib.SOURCE_CONTINUE;
        });
        GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 7, () => {
            this._stopFlash();
            return GLib.SOURCE_REMOVE;
        });
    }

    _stopFlash() {
        if (this._flashId) {
            GLib.source_remove(this._flashId);
            this._flashId = 0;
        }
        this._icon.opacity = 255;
    }

    _refreshMenu() {
        this._statusItem.label.text =
            `stato: ${stateLabel(this._state)} - ${this._live} istanze opencode`;
        this._costItem.label.text =
            `opencode: ca. ${this._cost.toFixed(2)} $`;

        this._projectsItem.menu.removeAll();

        if (this._sessions.length === 0) {
            const none = new PopupMenu.PopupMenuItem(
                'nessuna istanza opencode attiva', {reactive: false});
            this._projectsItem.menu.addMenuItem(none);
            return;
        }

        const groups = new Map();
        for (const s of this._sessions) {
            const name = s.project || '?';
            let g = groups.get(name);
            if (!g) {
                g = {count: 0, active: false, reason: ''};
                groups.set(name, g);
            }
            g.count++;
            if (s.state === 'working' || s.state === 'attention')
                g.active = true;
            if (s.reason && !g.reason)
                g.reason = s.reason;
        }

        const names = [...groups.keys()].sort();
        for (const name of names) {
            const g = groups.get(name);
            let txt = `${name} ${g.active ? '[lavorando]' : '[fermo]'}`;
            if (g.count > 1)
                txt += ` (${g.count} sessioni)`;
            if (g.reason)
                txt += `: ${g.reason}`;
            const item = new PopupMenu.PopupMenuItem(txt, {reactive: false});
            this._projectsItem.menu.addMenuItem(item);
        }
    }

    destroy() {
        this._stopFlash();
        if (this._pollId) {
            GLib.source_remove(this._pollId);
            this._pollId = 0;
        }
        super.destroy();
    }
});

export default class OpencodeTrayExtension extends Extension {
    enable() {
        this._indicator = new Indicator(this);
        const pos = readJson(SETTINGS_FILE)?.position ?? 'right';
        const cfg = POSITIONS[pos] ?? POSITIONS.right;
        Main.panel.addToStatusArea(
            'opencode-tray', this._indicator, cfg.index, cfg.section);
    }

    // Sposta l'indicatore a shell viva (nessun logout necessario).
    reposition(section, index) {
        const actor = this._indicator;
        if (!actor)
            return;

        const panel = Main.panel;
        const boxes = {
            left: panel._leftBox,
            center: panel._centerBox,
            right: panel._rightBox,
        };
        const box = boxes[section] ?? panel._rightBox;
        if (!box)
            return;

        const parent = actor.get_parent();
        if (parent)
            parent.remove_child(actor);

        const n = box.get_n_children();
        const i = Math.max(0, Math.min(index, n));
        box.insert_child_at_index(actor, i);
    }

    disable() {
        if (this._indicator) {
            this._indicator.destroy();
            this._indicator = null;
        }
    }
}

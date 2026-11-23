/* extension.js
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
import Clutter from 'gi://Clutter';
import GObject from 'gi://GObject';
import St from 'gi://St';
import Gio from 'gi://Gio';
import Meta from 'gi://Meta';
import Shell from 'gi://Shell';
import Pango from 'gi://Pango';

import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as AltTab from 'resource:///org/gnome/shell/ui/altTab.js';
import * as SwitcherPopup from 'resource:///org/gnome/shell/ui/switcherPopup.js';
import * as AnimationUtils from 'resource:///org/gnome/shell/misc/animationUtils.js';

import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';

let _mruSerial = 0;
let _windowMru = null;

function _isUsableWindow(window) {
    return window && !window.skip_taskbar;
}

function _touchWindow(window) {
    if (_isUsableWindow(window)) {
        _mruSerial += 1;
        _windowMru.set(window, _mruSerial);
    }
}

function getWindows(workspace) {
    const rawList = global.display.get_tab_list(Meta.TabList.NORMAL_ALL, workspace);
    const seen = new Set();
    const processed = [];

    for (let i = 0; i < rawList.length; i++) {
        let w = rawList[i];
        if (w.is_attached_dialog()) {
            w = w.get_transient_for();
        }

        if (!_isUsableWindow(w) || seen.has(w)) {
            continue;
        }
        
        seen.add(w);
        processed.push({
            window: w,
            serial: _windowMru.get(w) ?? -1,
            index: i
        });
    }

    return processed
        .sort((a, b) => (b.serial - a.serial) || (a.index - b.index))
        .map(entry => entry.window);
}

const SimpleWindowItem = GObject.registerClass(
class SimpleWindowItem extends St.BoxLayout {
    _init(window) {
        super._init({
            style_class: 'alt-tab-vertical-item',
            orientation: Clutter.Orientation.HORIZONTAL,
            x_expand: true,
        });

        this.window = window;
        const tracker = Shell.WindowTracker.get_default();
        this.app = tracker.get_window_app(window);

        const iconSize = 32;
        const icon = this.app !== null
            ? this.app.create_icon_texture(iconSize)
            : new St.Icon({
                icon_name: 'applications-other-symbolic',
                icon_size: iconSize,
            });

        const iconBin = new St.Bin({
            x_align: Clutter.ActorAlign.START,
            y_align: Clutter.ActorAlign.CENTER,
        });
        iconBin.child = icon;
        this.add_child(iconBin);
        
        const title = window.get_title() || (this.app !== null ? this.app.get_name() : '');

        this.label = new St.Label({
            text: title,
            style_class: 'alt-tab-vertical-title',
            x_align: Clutter.ActorAlign.START,
            y_align: Clutter.ActorAlign.CENTER,
            x_expand: true,
        });

        // Show ellipsis when the title is too long
        const text = this.label.clutter_text;
        text.ellipsize = Pango.EllipsizeMode.END;
        text.line_wrap = false;

        this.add_child(this.label);
    }
});

const VerticalWindowSwitcher = GObject.registerClass(
class VerticalWindowSwitcher extends SwitcherPopup.SwitcherList {
    // Override to prevent mouse hover from changing the selected item.
    // The base class calls _itemEntered() here which eventually triggers
    // _select(), causing the highlight to follow the pointer while the
    // user is holding Alt.  We suppress that and only honour real clicks.
    _onItemMotion(_item) {
        return Clutter.EVENT_PROPAGATE;
    }

    _init(windows) {
        super._init(false);

        this.add_style_class_name('vertical-switcher-list');

        // Make the internal container vertical instead of horizontal,
        // and remove spacing between rows so items are stacked tightly.
        if (this._list instanceof St.BoxLayout) {
            this._list.orientation = Clutter.Orientation.VERTICAL;
            this._list.spacing = 0;
        }

            // Allow vertical scrolling when there are many windows
        if (this._scrollView) {
            this._scrollView.enable_mouse_scrolling = true;
            this._scrollView.hscrollbar_policy = St.PolicyType.NEVER;
            this._scrollView.vscrollbar_policy = St.PolicyType.AUTOMATIC;
        }

        this.windows = windows;
        this.icons = [];

        for (const win of windows) {
            const item = new SimpleWindowItem(win);

            this.addItem(item, item.label);
            this.icons.push(item);

            win.connectObject('unmanaged', window => {
                this._removeWindow(window);
            }, this);
        }
    }

    vfunc_get_preferred_height(_forWidth) {
        // For a vertical list we want the sum of all item heights so multiple
        // rows are visible, but we cap the natural height to 80% of the monitor
        // so scrolling can take over beyond that.
        let minHeight = 0;
        let natHeight = 0;

        for (const item of this._items) {
            const [childMin, childNat] = item.get_preferred_height(-1);
            minHeight += childMin;
            natHeight += childNat;
        }

        const primary = Main.layoutManager.primaryMonitor;
        const maxNat = Math.floor(primary.height * 0.8);

        // Natural height is whatever our children need, but never more
        // than 80% of the monitor height.
        natHeight = Math.min(natHeight, maxNat);
        minHeight = Math.min(minHeight, natHeight);

        const themeNode = this.get_theme_node();
        return themeNode.adjust_preferred_height(minHeight, natHeight);
    }

    vfunc_get_preferred_width(forHeight) {
        const [minWidth, natWidth] = super.vfunc_get_preferred_width(forHeight);
        
        // Keep width within [480px, 680px]:
        const minDesired = 480;
        const maxDesired = 680;

        const newNat = Math.max(minDesired, Math.min(natWidth, maxDesired));
        const newMin = Math.min(Math.max(minWidth, minDesired), newNat);

        const themeNode = this.get_theme_node();
        return themeNode.adjust_preferred_width(newMin, newNat);
    }

    highlight(index, justOutline) {
        super.highlight(index, justOutline);

        if (index === -1 || !this._scrollView) {
            return;
        }

        const item = this._items[index];
        AnimationUtils.ensureActorVisibleInScrollView(this._scrollView, item);
    }

    destroy() {
        for (const icon of this.icons) {
            if (icon.window) {
                icon.window.disconnectObject(this);
            }
            icon.destroy();
        }
        this.icons = [];
        super.destroy();
    }

    _removeWindow(window) {
        const index = this.icons.findIndex(icon => icon.window === window);
        if (index === -1) {
            return;
        }

        window.disconnectObject(this);

        this.icons.splice(index, 1);
        this.removeItem(index);
    }
});

let _originalInit = null;

export default class AltTabListExtension extends Extension {
    _seedMru() {
        const rawList = global.display.get_tab_list(Meta.TabList.NORMAL_ALL, null);
        const seen = new Set();
        const windowsToSeed = [];

        for (let w of rawList) {
            if (w.is_attached_dialog()) w = w.get_transient_for();
            if (_isUsableWindow(w) && !seen.has(w)) {
                seen.add(w);
                windowsToSeed.push(w);
            }
        }

        for (let i = windowsToSeed.length - 1; i >= 0; i--) {
            _touchWindow(windowsToSeed[i]);
        }
    }

    enable() {
        const proto = AltTab.WindowSwitcherPopup.prototype;

        _originalInit = proto._init;

        _windowMru = new WeakMap();
        _mruSerial = 0;
        this._seedMru();

        global.display.connectObject(
            'notify::focus-window', () => _touchWindow(global.display.focus_window),
            'window-created', (_display, window) => _touchWindow(window),
            this
        );
        _touchWindow(global.display.focus_window);

        proto._init = function () {
            SwitcherPopup.SwitcherPopup.prototype._init.call(this);

            if (this._switcherList) {
                this._switcherList.destroy();
            }

            const settings = new Gio.Settings({
                schema_id: 'org.gnome.shell.window-switcher',
            });

            let workspace = null;
            if (settings.get_boolean('current-workspace-only')) {
                workspace = global.workspace_manager.get_active_workspace();
            }

            const windows = getWindows(workspace);

            const switcherList = new VerticalWindowSwitcher(windows);
            this._switcherList = switcherList;
            this._items = switcherList.icons;

            const origKeyPress = SwitcherPopup.SwitcherPopup.prototype._keyPressHandler;
            this._keyPressHandler = function(keysym, action) {
                if (keysym === Clutter.KEY_Shift_L || keysym === Clutter.KEY_Shift_R) {
                    this._select(this._previous());
                    return Clutter.EVENT_STOP;
                }
                if (keysym === Clutter.KEY_Tab || keysym === Clutter.KEY_ISO_Left_Tab) {
                    this._select(this._next());
                    return Clutter.EVENT_STOP;
                }
                return origKeyPress.call(this, keysym, action);
            };
        };
    }

    disable() {
        const proto = AltTab.WindowSwitcherPopup.prototype;

        if (_originalInit !== null) {
            proto._init = _originalInit;
        }

        global.display.disconnectObject(this);

        _windowMru = null;
        _mruSerial = 0;
        _originalInit = null;
    }
}
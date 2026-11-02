import Glib from "gi://GLib";
import Gio from "gi://Gio";
import Shell from "gi://Shell";
import { fileExists, readFile, uniqueId } from "./util.js";
export default class VSCodeSearchProvider {
    workspaces = {};
    extension;
    app;
    appInfo;
    // Set by the SearchProvider interface
    display;
    constructor(extension) {
        this.extension = extension;
        this._setApp();
        this.appInfo = this.app?.appInfo;
        this._setWorkspaces();
    }
    _setWorkspaces() {
        const codeConfig = this._getConfig();
        if (!codeConfig) {
            console.error("Failed to read vscode storage.json");
            return;
        }
        const addSuffix = this.extension?._settings?.get_boolean("suffix");
        const workspaceTypes = [
            {
                type: "dev-container",
                enabled: this.extension?._settings?.get_boolean("include-dev-containers"),
                isWorkspaceType: (path) => path.startsWith("vscode-remote://dev-container"),
                makeDisplayName: (name) => name + (addSuffix ? " [Dev Container]" : ""),
            },
            {
                type: "codespace",
                enabled: this.extension?._settings?.get_boolean("include-code-spaces"),
                isWorkspaceType: (path) => path.startsWith("vscode-remote://codespaces"),
                makeDisplayName: (name) => name + (addSuffix ? " [Codespaces]" : ""),
            },
            {
                type: "github",
                enabled: this.extension?._settings?.get_boolean("include-github"),
                isWorkspaceType: (path) => path.startsWith("vscode-vfs://github"),
                makeDisplayName: (name) => name + (addSuffix ? " [Github]" : ""),
            },
            {
                type: "remote",
                enabled: true,
                isWorkspaceType: (path) => path.startsWith("vscode-remote://"),
                makeDisplayName: (name) => name + (addSuffix ? " [Remote]" : ""),
            },
            {
                type: "default",
                enabled: true,
                isWorkspaceType: () => true,
                makeDisplayName: (name) => name,
            },
        ];
        const paths = Object.keys(codeConfig.profileAssociations.workspaces);
        const validWorkspaces = paths
            .map(decodeURIComponent)
            .map((path) => ({
            path,
            type: workspaceTypes.find((type) => type.isWorkspaceType(path)),
        }))
            .filter(({ type }) => type.enabled)
            .map(({ path, type }) => ({
            name: type
                .makeDisplayName(path.split("/").pop())
                .replace(".code-workspace", " Workspace"),
            path: path.replace("file://", ""),
        }));
        this.workspaces = {};
        for (const workspace of validWorkspaces) {
            this.workspaces[uniqueId()] = workspace;
        }
    }
    _getConfig() {
        const configDirs = [
            Glib.get_user_config_dir(),
            `${Glib.get_home_dir()}/.var/app`,
        ];
        const appDirs = [
            // XDG_CONFIG_DIRS
            "Code",
            "Code - Insiders",
            "VSCodium",
            "VSCodium - Insiders",
            // Flatpak
            "com.vscodium.codium/config/VSCodium",
            "com.vscodium.codium-insiders/config/VSCodium - Insiders",
        ];
        for (const configDir of configDirs) {
            for (const appDir of appDirs) {
                const path = `${configDir}/${appDir}/User/globalStorage/storage.json`;
                if (!fileExists(path)) {
                    continue;
                }
                const storage = readFile(path);
                if (storage) {
                    return JSON.parse(storage);
                }
            }
        }
    }
    _setApp() {
        this.app = [
            "code",
            "com.microsoft.VSCode",
            "code-insiders",
            "com.microsoft.VSCodeInsiders",
            "code-oss",
            "codium",
            "codium-insiders",
            "com.vscodium.codium",
            "com.vscodium.codium-insiders",
        ]
            .map((id) => Shell.AppSystem.get_default().lookup_app(id + ".desktop"))
            .find((app) => Boolean(app));
        if (!this.app) {
            console.error("Failed to find vscode application");
        }
    }
    activateResult(result) {
        if (this.app) {
            const path = this.workspaces[result].path;
            if (path.startsWith("vscode-remote://") ||
                path.startsWith("vscode-vfs://")) {
                const lastSegment = path.split("/").pop();
                const type = lastSegment?.slice(1)?.includes(".") ? "file" : "folder";
                const command = this.app?.app_info.get_executable() + " --" + type + "-uri " + path;
                Glib.spawn_command_line_async(command);
            }
            else {
                this.app?.app_info.launch([Gio.file_new_for_path(path)], null);
            }
        }
    }
    filterResults(results, maxResults) {
        return results.slice(0, maxResults);
    }
    async getInitialResultSet(terms) {
        this._setWorkspaces();
        const searchTerm = terms.join("").toLowerCase();
        return Object.keys(this.workspaces).filter((id) => this.workspaces[id].name.toLowerCase().includes(searchTerm));
    }
    async getSubsearchResultSet(previousResults, terms) {
        const searchTerm = terms.join("").toLowerCase();
        return previousResults.filter((id) => this.workspaces[id].name.toLowerCase().includes(searchTerm));
    }
    async getResultMetas(ids) {
        return ids.map((id) => ({
            id,
            name: this.workspaces[id].name,
            description: this.workspaces[id].path,
            createIcon: (size) => this.app?.create_icon_texture(size),
        }));
    }
}

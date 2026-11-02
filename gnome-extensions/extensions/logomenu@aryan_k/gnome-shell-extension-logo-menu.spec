%global uuid logomenu@aryan_k

Name:          gnome-shell-extension-logo-menu
Version:       1.{{{ git_dir_version }}}
Release:       1%{?dist}
Summary:       Quick access menu for the GNOME panel

Group:         User Interface/Desktops
License:       GPLv2
URL:           https://github.com/ublue-os/Logomenu
Source0:       %{url}/archive/refs/heads/main.tar.gz
Source1:       %{url}/archive/refs/heads/gnome-44.tar.gz
BuildArch:     noarch

BuildRequires: unzip
BuildRequires: gettext
BuildRequires: gnome-shell
BuildRequires: glib2

Requires:    gnome-shell >= 3.12
%description
Quick access menu for the GNOME panel with options that help ease the workflow for newcomers and power users alike. 

%prep
%if 0%{?fedora} == 38
%setup -b 1 -n Logomenu-gnome-44
%else
%setup -n Logomenu-main
%endif

%install
mkdir -p %{buildroot}%{_bindir}
mv distroshelf-helper %{buildroot}%{_bindir}
mv missioncenter-helper %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
mv po PrefsLib Resources schemas *.js *.json *.css %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
glib-compile-schemas %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/schemas/

%files
%license LICENSE
%{_datadir}/gnome-shell/extensions/%{uuid}/
%{_bindir}/distroshelf-helper
%{_bindir}/missioncenter-helper

%changelog
{{{ git_dir_changelog }}}

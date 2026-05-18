pkgname=koretoggle-git
pkgver=0
pkgrel=1
pkgdesc="KDE Plasma 6 panel widget for toggling individual CPU cores on and off at runtime"
arch=('x86_64')
url="https://github.com/DanielGekeler/koretoggle"
license=('GPL-2.0-or-later')
depends=('plasma-workspace' 'qt6-declarative' 'polkit')
makedepends=('cmake' 'git')
provides=('koretoggle')
conflicts=('koretoggle')
source=("$pkgname::git+https://github.com/DanielGekeler/koretoggle.git")
sha256sums=('SKIP')

pkgver() {
    cd "$pkgname"
    printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

build() {
    cd "$pkgname"
    cmake -S plugin -B plugin/build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr
    cmake --build plugin/build
}

package() {
    cd "$pkgname"

    # QML plugin (installs .so, qmldir, .qmltypes)
    DESTDIR="$pkgdir" cmake --install plugin/build

    # Helper script
    install -Dm755 koretoggle-helper \
        "$pkgdir/usr/lib/koretoggle-helper"

    # Polkit policy
    install -Dm644 org.koretoggle.toggle.policy \
        "$pkgdir/usr/share/polkit-1/actions/org.koretoggle.toggle.policy"

    # Plasmoid
    install -Dm644 metadata.json \
        "$pkgdir/usr/share/plasma/plasmoids/org.koretoggle.plasmoid/metadata.json"
    install -Dm644 contents/ui/main.qml \
        "$pkgdir/usr/share/plasma/plasmoids/org.koretoggle.plasmoid/contents/ui/main.qml"
}

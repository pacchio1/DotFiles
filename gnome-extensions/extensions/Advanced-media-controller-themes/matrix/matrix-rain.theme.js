// Advanced Media Controller - Example User Theme: Matrix Rain
//
// Install: copy this file to
//   ~/.local/share/gnome-shell/extensions/media-controller-themes/matrix-rain.theme.js
// Or use Extensions > Advanced Media Controller > Progress Bar > Install Theme File
//
// Full API reference is in the built-in "Create New Theme" template.

const theme = {
    id: "matrix-rain",
    label: "Matrix Rain",
    author: "Example Author",
    version: "1.0",

    _drops: null,
    _initDrops(trackW) {
        if (this._drops && this._drops.length > 0) return;
        this._drops = [];
        const count = Math.max(4, Math.floor(trackW / 18));
        for (let i = 0; i < count; i++) {
            this._drops.push({
                x: Math.random() * trackW,
                y: Math.random() * 20 - 20,
                speed: 0.8 + Math.random() * 1.4,
                alpha: 0.3 + Math.random() * 0.7,
                len: 6 + Math.floor(Math.random() * 10),
            });
        }
    },

    drawTrack(ctx) {
        const { cr, margin, trackY, trackW, fillEnd, offset, W, H, ratio } = ctx;

        this._initDrops(trackW);

        cr.save();

        cr.setLineWidth(5);
        cr.setLineCap(Cairo.LineCap.ROUND);
        cr.setSourceRGBA(0.0, 0.08, 0.0, 0.6);
        cr.moveTo(margin, trackY);
        cr.lineTo(margin + trackW, trackY);
        cr.stroke();

        if (ratio > 0) {
            const g = new Cairo.LinearGradient(margin, 0, fillEnd, 0);
            g.addColorStopRGBA(0.0, 0.0, 0.4, 0.0, 1.0);
            g.addColorStopRGBA(0.6, 0.0, 0.8, 0.05, 1.0);
            g.addColorStopRGBA(1.0, 0.2, 1.0, 0.2, 1.0);
            cr.setSource(g);
            cr.setLineWidth(5);
            cr.moveTo(margin, trackY);
            cr.lineTo(fillEnd, trackY);
            cr.stroke();
        }

        const chars = "01アイウエオカキクケコ";
        const CHAR_H = 8;
        const step = 0.04;

        for (const d of this._drops) {
            d.y += d.speed * step;
            if (d.y > 16) { d.y = -d.len * CHAR_H * 0.1; d.x = Math.random() * trackW; }

            const px = margin + d.x;
            if (px > fillEnd) continue;

            for (let j = 0; j < d.len; j++) {
                const py = trackY - 6 + d.y - j * 2;
                if (py < trackY - 8 || py > trackY + 8) continue;
                const fade = 1 - j / d.len;
                const alpha = d.alpha * fade * 0.7;
                const g2 = j === 0 ? 1.0 : 0.55 + fade * 0.35;
                cr.setSourceRGBA(0, g2, 0, alpha);
                cr.setLineWidth(1);
                cr.arc(px, py, 0.7, 0, Math.PI * 2);
                cr.fill();
            }
        }

        if (ratio > 0.02) {
            const pulse = Math.sin(offset * 0.2) * 0.5 + 0.5;
            const glow = new Cairo.RadialGradient(fillEnd, trackY, 0, fillEnd, trackY, 12 + pulse * 4);
            glow.addColorStopRGBA(0, 0.4, 1.0, 0.4, 0.9);
            glow.addColorStopRGBA(0.5, 0.0, 0.8, 0.0, 0.4);
            glow.addColorStopRGBA(1, 0.0, 0.4, 0.0, 0.0);
            cr.setSource(glow);
            cr.arc(fillEnd, trackY, 12 + pulse * 4, 0, Math.PI * 2);
            cr.fill();
        }

        cr.restore();
    },

    drawThumb(ctx) {
        const { cr, cx, cy, r, offset, pixbuf } = ctx;

        if (pixbuf) {
            try {
                const { Gdk } = globalThis._themeGdk ?? {};
                if (Gdk) {
                    cr.save();
                    cr.arc(cx, cy, r, 0, Math.PI * 2);
                    cr.clip();
                    Gdk.cairo_set_source_pixbuf(cr, pixbuf, 0, 0);
                    cr.paint();
                    cr.restore();
                    return;
                }
            } catch (_) {}
        }

        const pulse = Math.sin(offset * 0.2) * 0.5 + 0.5;

        cr.save();

        const outerGlow = new Cairo.RadialGradient(cx, cy, 0, cx, cy, r + 8 + pulse * 3);
        outerGlow.addColorStopRGBA(0, 0.0, 1.0, 0.0, 0.8);
        outerGlow.addColorStopRGBA(0.5, 0.0, 0.6, 0.0, 0.3);
        outerGlow.addColorStopRGBA(1, 0.0, 0.3, 0.0, 0.0);
        cr.setSource(outerGlow);
        cr.arc(cx, cy, r + 8 + pulse * 3, 0, Math.PI * 2);
        cr.fill();

        const bg = new Cairo.RadialGradient(cx - r * 0.25, cy - r * 0.3, 0, cx, cy, r);
        bg.addColorStopRGBA(0, 0.15, 0.9, 0.15, 1.0);
        bg.addColorStopRGBA(0.5, 0.0, 0.55, 0.0, 1.0);
        bg.addColorStopRGBA(1, 0.0, 0.2, 0.0, 1.0);
        cr.setSource(bg);
        cr.arc(cx, cy, r, 0, Math.PI * 2);
        cr.fill();

        for (let ring = 1; ring <= 2; ring++) {
            cr.setSourceRGBA(0.0, 1.0, 0.0, 0.25 - ring * 0.08);
            cr.setLineWidth(1);
            cr.arc(cx, cy, r * (0.4 + ring * 0.28), 0, Math.PI * 2);
            cr.stroke();
        }

        const t = offset * 0.06;
        cr.setSourceRGBA(0.4, 1.0, 0.4, 0.7);
        cr.setLineWidth(1.5);
        cr.setLineCap(Cairo.LineCap.ROUND);
        const bx = cx + Math.cos(t) * r * 0.3;
        const by = cy + Math.sin(t) * r * 0.3;
        cr.arc(bx, by, 1.5, 0, Math.PI * 2);
        cr.fill();

        cr.setSourceRGBA(0.6, 1.0, 0.6, 0.3);
        cr.setLineWidth(1);
        cr.arc(cx, cy, r - 0.75, 0, Math.PI * 2);
        cr.stroke();

        cr.restore();
    },
};
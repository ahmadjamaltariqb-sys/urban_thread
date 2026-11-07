Add-Type -AssemblyName System.Drawing

$code = @"
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class StudioGarmentFinishV2 {
    public static void Process(string inPath, string outPath, int mode, int tr, int tg, int tb, float strength) {
        using (Bitmap src = new Bitmap(inPath)) {
            int w = src.Width;
            int h = src.Height;
            Bitmap dst = new Bitmap(w, h, PixelFormat.Format24bppRgb);

            using (Bitmap polyBmp = new Bitmap(w, h, PixelFormat.Format24bppRgb)) {
                using (Graphics g = Graphics.FromImage(polyBmp)) {
                    g.SmoothingMode = SmoothingMode.AntiAlias;
                    g.Clear(Color.Black);
                    using (SolidBrush whiteBrush = new SolidBrush(Color.White)) {
                        using (SolidBrush blackBrush = new SolidBrush(Color.Black)) {
                            if (mode == 4) {
                                // Exact outer contour of the shirt in p4_base.jpg
                                PointF[] pts = new PointF[] {
                                    new PointF(w*0.455f, h*0.295f), // left collar top
                                    new PointF(w*0.435f, h*0.315f),
                                    new PointF(w*0.332f, h*0.368f), // left shoulder
                                    new PointF(w*0.298f, h*0.412f),
                                    new PointF(w*0.268f, h*0.480f), // left outer sleeve
                                    new PointF(w*0.235f, h*0.606f), // left sleeve outer cuff corner
                                    new PointF(w*0.365f, h*0.618f), // left sleeve inner cuff corner
                                    new PointF(w*0.365f, h*0.665f), // left waist corner
                                    new PointF(w*0.485f, h*0.688f), // bottom hem left-center
                                    new PointF(w*0.615f, h*0.692f), // bottom hem right-center
                                    new PointF(w*0.775f, h*0.672f), // right waist corner
                                    new PointF(w*0.798f, h*0.635f),
                                    new PointF(w*0.818f, h*0.606f), // right sleeve inner cuff corner
                                    new PointF(w*0.994f, h*0.590f), // right sleeve outer cuff corner
                                    new PointF(w*0.928f, h*0.460f), // right outer sleeve mid
                                    new PointF(w*0.872f, h*0.365f), // right shoulder curve
                                    new PointF(w*0.805f, h*0.322f),
                                    new PointF(w*0.665f, h*0.278f), // right collar outer
                                    new PointF(w*0.622f, h*0.268f), // right collar top
                                    new PointF(w*0.612f, h*0.305f), // right inner neck
                                    new PointF(w*0.518f, h*0.425f), // V-neck bottom point
                                    new PointF(w*0.472f, h*0.335f)  // left inner neck
                                };
                                g.FillPolygon(whiteBrush, pts);
                            } else if (mode == 6) {
                                // p6: Leather Tote (avoiding coffee mug in top-right)
                                PointF[] pts = new PointF[] {
                                    new PointF(w*0.33f, h*0.14f),
                                    new PointF(w*0.71f, h*0.14f),
                                    new PointF(w*0.82f, h*0.275f),
                                    new PointF(w*0.78f, h*0.92f),
                                    new PointF(w*0.35f, h*0.80f)
                                };
                                g.FillPolygon(whiteBrush, pts);
                            } else if (mode == 9) {
                                // c1: Left draped sweatshirt + Middle draped hoodie
                                PointF[] pts = new PointF[] {
                                    new PointF(w*0.465f, h*0.34f),
                                    new PointF(w*0.69f, h*0.34f),
                                    new PointF(w*0.675f, h*0.90f),
                                    new PointF(w*0.465f, h*0.75f)
                                };
                                g.FillPolygon(whiteBrush, pts);
                            } else if (mode == 10) {
                                // b1: Pleated trousers
                                PointF[] pts = new PointF[] {
                                    new PointF(w*0.43f, h*0.382f),
                                    new PointF(w*0.56f, h*0.382f),
                                    new PointF(w*0.585f, h*0.912f),
                                    new PointF(w*0.45f, h*0.912f)
                                };
                                g.FillPolygon(whiteBrush, pts);
                            } else if (mode == 11) {
                                // b2: Olive Linen Overshirt (only exclude neck skin at top, white tee excluded by luminance!)
                                PointF[] pts = new PointF[] {
                                    new PointF(w*0.455f, h*0.245f),
                                    new PointF(w*0.472f, h*0.315f),
                                    new PointF(w*0.530f, h*0.315f),
                                    new PointF(w*0.550f, h*0.245f),
                                    new PointF(w*0.620f, h*0.320f),
                                    new PointF(w*0.655f, h*0.580f),
                                    new PointF(w*0.605f, h*0.835f),
                                    new PointF(w*0.372f, h*0.888f),
                                    new PointF(w*0.360f, h*0.580f),
                                    new PointF(w*0.385f, h*0.320f)
                                };
                                g.FillPolygon(whiteBrush, pts);
                            }
                        }
                    }
                }

                Rectangle rect = new Rectangle(0, 0, w, h);
                BitmapData srcData = src.LockBits(rect, ImageLockMode.ReadOnly, PixelFormat.Format24bppRgb);
                BitmapData polyData = polyBmp.LockBits(rect, ImageLockMode.ReadOnly, PixelFormat.Format24bppRgb);
                BitmapData dstData = dst.LockBits(rect, ImageLockMode.WriteOnly, PixelFormat.Format24bppRgb);

                int stride = srcData.Stride;
                int bytes = Math.Abs(stride) * h;
                byte[] rgb = new byte[bytes];
                byte[] poly = new byte[bytes];
                byte[] outRgb = new byte[bytes];

                Marshal.Copy(srcData.Scan0, rgb, 0, bytes);
                Marshal.Copy(polyData.Scan0, poly, 0, bytes);
                Array.Copy(rgb, outRgb, bytes);

                float[] mask = new float[w * h];
                for (int y = 0; y < h; y++) {
                    int row = y * stride;
                    float ny = (float)y / h;
                    for (int x = 0; x < w; x++) {
                        int idx = row + x * 3;
                        float pVal = poly[idx] / 255.0f;
                        if (pVal <= 0.01f) continue;

                        float nx = (float)x / w;
                        byte b = rgb[idx];
                        byte g = rgb[idx + 1];
                        byte r = rgb[idx + 2];
                        float lum = 0.299f * r + 0.587f * g + 0.114f * b;

                        bool ok = true;
                        if (mode == 4) {
                            // Only exclude dark pants at bottom boundary or dark skin at sleeve boundary
                            if (ny > 0.64f && lum < 95) ok = false;
                            if ((nx < 0.36f || nx > 0.80f) && ny > 0.58f && lum < 120) ok = false;
                        } else if (mode == 6) {
                            if (lum > 118) ok = false;
                        } else if (mode == 9) {
                            // Dark charcoal hoodie vs warm beige limestone & right cream shirt
                            if (lum > 130) ok = false;
                        } else if (mode == 10) {
                            if (lum > 142) ok = false;
                            if (lum < 32 && (r - b) < 8 && ny < 0.43f) ok = false;
                        } else if (mode == 11) {
                            // Exclude white inner T-shirt (high lum, low saturation)
                            if (nx > 0.475f && nx < 0.535f && lum > 155) ok = false;
                            // Exclude dark blue jeans at bottom (b > g)
                            if (ny > 0.80f && b > g) ok = false;
                            // Exclude skin (hand/wrist)
                            if ((r - g) > 22 && ny > 0.75f) ok = false;
                            // Exclude bright window on right shoulder edge
                            if (nx > 0.60f && ny < 0.45f && lum > 140) ok = false;
                            // Exclude dark background rack on left shoulder edge
                            if (nx < 0.40f && ny < 0.42f && lum < 55) ok = false;
                        }

                        if (ok) mask[y * w + x] = pVal;
                    }
                }

                // Smooth 3px feather for seamless anti-aliased edge
                float[] smooth = new float[w * h];
                int rad = 3;
                for (int y = rad; y < h - rad; y++) {
                    for (int x = rad; x < w - rad; x++) {
                        float sum = 0;
                        int count = 0;
                        for (int dy = -rad; dy <= rad; dy++) {
                            int rOff = (y + dy) * w;
                            for (int dx = -rad; dx <= rad; dx++) {
                                sum += mask[rOff + x + dx];
                                count++;
                            }
                        }
                        smooth[y * w + x] = sum / count;
                    }
                }

                float targetLum = 0.299f * tr + 0.587f * tg + 0.114f * tb;
                for (int y = 0; y < h; y++) {
                    int row = y * stride;
                    for (int x = 0; x < w; x++) {
                        float m = smooth[y * w + x] * strength;
                        if (m <= 0.01f) continue;

                        int idx = row + x * 3;
                        byte b = rgb[idx];
                        byte g = rgb[idx + 1];
                        byte r = rgb[idx + 2];
                        float lum = 0.299f * r + 0.587f * g + 0.114f * b;

                        float nr, ng, nb;
                        if (mode == 4) {
                            float norm = lum / 218.0f;
                            if (targetLum < 60) {
                                // Jet Black poplin shirt: strong natural fold, pocket & button contrast
                                float centered = (lum - 208.0f) * 0.48f;
                                nr = tr + centered;
                                ng = tg + centered;
                                nb = tb + centered;
                            } else {
                                // Sage Mist poplin shirt
                                float curve = 0.35f + 0.72f * norm;
                                nr = tr * curve;
                                ng = tg * curve;
                                nb = tb * curve;
                            }
                        } else if (mode == 10 && targetLum > 160) {
                            float norm = lum / 68.0f;
                            float shaped = (float)Math.Pow(Math.Max(0.15f, norm), 0.65f);
                            nr = tr * shaped;
                            ng = tg * shaped;
                            nb = tb * shaped;
                        } else if (mode == 11 && targetLum > 160) {
                            float norm = lum / 98.0f;
                            float shaped = (float)Math.Pow(Math.Max(0.15f, norm), 0.72f);
                            nr = tr * shaped;
                            ng = tg * shaped;
                            nb = tb * shaped;
                        } else if (mode == 9 && targetLum > 110) {
                            // Stone Grey hoodie: subtle lighten while keeping realistic fold depth
                            float ratio = (lum + 35.0f) / 95.0f;
                            nr = tr * ratio;
                            ng = tg * ratio;
                            nb = tb * ratio;
                        } else {
                            float refLum = (mode == 11) ? 95.0f : (mode == 10 ? 70.0f : (mode == 9 ? 70.0f : 65.0f));
                            float ratio = (lum + 12.0f) / (refLum + 12.0f);
                            nr = tr * ratio;
                            ng = tg * ratio;
                            nb = tb * ratio;
                        }

                        nr = Math.Max(0, Math.Min(255, nr));
                        ng = Math.Max(0, Math.Min(255, ng));
                        nb = Math.Max(0, Math.Min(255, nb));

                        outRgb[idx]     = (byte)(b * (1 - m) + nb * m);
                        outRgb[idx + 1] = (byte)(g * (1 - m) + ng * m);
                        outRgb[idx + 2] = (byte)(r * (1 - m) + nr * m);
                    }
                }

                Marshal.Copy(outRgb, 0, dstData.Scan0, bytes);
                src.UnlockBits(srcData);
                polyBmp.UnlockBits(polyData);
                dst.UnlockBits(dstData);
            }

            ImageCodecInfo jpgEncoder = null;
            foreach (ImageCodecInfo codec in ImageCodecInfo.GetImageEncoders()) {
                if (codec.FormatID == ImageFormat.Jpeg.Guid) { jpgEncoder = codec; break; }
            }
            EncoderParameters ep = new EncoderParameters(1);
            ep.Param[0] = new EncoderParameter(System.Drawing.Imaging.Encoder.Quality, 95L);
            dst.Save(outPath, jpgEncoder, ep);
            dst.Dispose();
        }
    }
}
"@

Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing

$dir = "C:\Users\AHMED\.gemini\antigravity\scratch\stitch_urban_threads_fashion_store\images"

[StudioGarmentFinishV2]::Process("$dir\p4_base.jpg", "$dir\p4_black.jpg", 4, 34, 36, 38, 0.98)
[StudioGarmentFinishV2]::Process("$dir\p4_base.jpg", "$dir\p4_sage.jpg",  4, 156, 172, 140, 0.96)
[StudioGarmentFinishV2]::Process("$dir\p6_espresso.jpg", "$dir\p6_black.jpg", 6, 22, 22, 24, 0.96)
[StudioGarmentFinishV2]::Process("$dir\c1_base.jpg", "$dir\c1_grey.jpg",     9, 132, 130, 126, 0.92)
[StudioGarmentFinishV2]::Process("$dir\c1_base.jpg", "$dir\c1_obsidian.jpg", 9, 22, 22, 20, 0.95)
[StudioGarmentFinishV2]::Process("$dir\b1_base.jpg", "$dir\b1_black.jpg",   10, 22, 22, 24, 0.96)
[StudioGarmentFinishV2]::Process("$dir\b1_base.jpg", "$dir\b1_oatmeal.jpg", 10, 205, 198, 184, 0.94)
[StudioGarmentFinishV2]::Process("$dir\b2_base.jpg", "$dir\b2_flax.jpg",  11, 208, 198, 182, 0.94)
[StudioGarmentFinishV2]::Process("$dir\b2_base.jpg", "$dir\b2_slate.jpg", 11, 42, 52, 60, 0.96)

Write-Output "V2 Studio Garment Finish Complete!"

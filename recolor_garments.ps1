Add-Type -AssemblyName System.Drawing

$imgDir = "C:\Users\AHMED\.gemini\antigravity\scratch\stitch_urban_threads_fashion_store\images"

$code = @"
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class GarmentRecolorV2
{
    public static void ProcessVariant(
        string inputPath,
        string outputPath,
        string mode,
        int targetR, int targetG, int targetB,
        float lumScale, float contrast, float colorStrength)
    {
        using (Bitmap bmp = new Bitmap(inputPath))
        {
            int w = bmp.Width;
            int h = bmp.Height;
            Rectangle rect = new Rectangle(0, 0, w, h);
            BitmapData data = bmp.LockBits(rect, ImageLockMode.ReadWrite, PixelFormat.Format24bppRgb);
            int stride = data.Stride;
            byte[] pixels = new byte[stride * h];
            Marshal.Copy(data.Scan0, pixels, 0, pixels.Length);

            float[] mask = BuildMask(pixels, w, h, stride, mode);
            float[] smoothMask = BlurMask(mask, w, h, 3);

            for (int y = 0; y < h; y++)
            {
                int row = y * stride;
                for (int x = 0; x < w; x++)
                {
                    float m = smoothMask[y * w + x];
                    if (m <= 0.01f) continue;

                    int idx = row + x * 3;
                    float b = pixels[idx];
                    float g = pixels[idx + 1];
                    float r = pixels[idx + 2];

                    float lum = (0.299f * r + 0.587f * g + 0.114f * b) / 255f;
                    float adjLum = (lum - 0.5f) * contrast + 0.5f;
                    adjLum = Math.Max(0.03f, Math.Min(0.97f, adjLum * lumScale));

                    float newR, newG, newB;
                    if (adjLum <= 0.5f)
                    {
                        float t = adjLum * 2.0f;
                        newR = targetR * t;
                        newG = targetG * t;
                        newB = targetB * t;
                    }
                    else
                    {
                        float t = (adjLum - 0.5f) * 2.0f;
                        newR = targetR + (255f - targetR) * t * 0.62f;
                        newG = targetG + (255f - targetG) * t * 0.62f;
                        newB = targetB + (255f - targetB) * t * 0.62f;
                    }

                    newR = r * (1f - colorStrength) + newR * colorStrength;
                    newG = g * (1f - colorStrength) + newG * colorStrength;
                    newB = b * (1f - colorStrength) + newB * colorStrength;

                    byte outR = (byte)Math.Max(0, Math.Min(255, r * (1f - m) + newR * m));
                    byte outG = (byte)Math.Max(0, Math.Min(255, g * (1f - m) + newG * m));
                    byte outB = (byte)Math.Max(0, Math.Min(255, b * (1f - m) + newB * m));

                    pixels[idx] = outB;
                    pixels[idx + 1] = outG;
                    pixels[idx + 2] = outR;
                }
            }

            Marshal.Copy(pixels, 0, data.Scan0, pixels.Length);
            bmp.UnlockBits(data);

            bmp.Save(outputPath, ImageFormat.Jpeg);
        }
    }

    private static bool PointInPoly(float px, float py, float[,] poly)
    {
        int n = poly.GetLength(0);
        bool inside = false;
        for (int i = 0, j = n - 1; i < n; j = i++)
        {
            float xi = poly[i, 0], yi = poly[i, 1];
            float xj = poly[j, 0], yj = poly[j, 1];
            if (((yi > py) != (yj > py)) && (px < (xj - xi) * (py - yi) / (yj - yi + 1e-6f) + xi))
                inside = !inside;
        }
        return inside;
    }

    private static float[] BuildMask(byte[] pixels, int w, int h, int stride, string mode)
    {
        float[] mask = new float[w * h];

        // Exact silhouette polygons
        float[,] p1Poly = new float[,] {
            {0.445f, 0.215f}, {0.505f, 0.242f}, {0.562f, 0.232f}, {0.655f, 0.268f},
            {0.732f, 0.405f}, {0.660f, 0.418f}, {0.688f, 0.520f}, {0.585f, 0.546f},
            {0.460f, 0.544f}, {0.390f, 0.508f}, {0.365f, 0.415f}, {0.252f, 0.402f},
            {0.312f, 0.258f}
        };

        float[,] p4Poly = new float[,] {
            {0.465f, 0.305f}, {0.520f, 0.422f}, {0.625f, 0.278f}, {0.830f, 0.342f},
            {0.988f, 0.585f}, {0.822f, 0.602f}, {0.798f, 0.485f}, {0.792f, 0.662f},
            {0.620f, 0.684f}, {0.460f, 0.680f}, {0.370f, 0.660f}, {0.368f, 0.608f},
            {0.238f, 0.600f}, {0.305f, 0.378f}
        };

        float[,] p5Poly = new float[,] {
            {0.352f, 0.178f}, {0.378f, 0.265f}, {0.405f, 0.178f}, {0.448f, 0.215f},
            {0.454f, 0.365f}, {0.422f, 0.385f}, {0.502f, 0.795f}, {0.420f, 0.832f},
            {0.310f, 0.822f}, {0.232f, 0.762f}, {0.330f, 0.400f}, {0.306f, 0.418f},
            {0.324f, 0.212f}
        };

        float[,] w2Poly = new float[,] {
            {0.482f, 0.160f}, {0.522f, 0.158f}, {0.562f, 0.198f}, {0.592f, 0.355f},
            {0.552f, 0.455f}, {0.512f, 0.445f}, {0.440f, 0.492f}, {0.418f, 0.530f},
            {0.435f, 0.340f}, {0.455f, 0.205f}
        };

        float[,] p6Poly = new float[,] {
            {0.342f, 0.190f}, {0.458f, 0.150f}, {0.695f, 0.185f}, {0.815f, 0.280f},
            {0.772f, 0.865f}, {0.692f, 0.912f}, {0.365f, 0.765f}
        };

        float[,] b2Poly = new float[,] {
            {0.468f, 0.245f}, {0.495f, 0.325f}, {0.495f, 0.840f}, {0.415f, 0.880f},
            {0.372f, 0.865f}, {0.368f, 0.580f}, {0.392f, 0.335f}
        };
        float[,] b2PolyRight = new float[,] {
            {0.538f, 0.245f}, {0.608f, 0.330f}, {0.652f, 0.585f}, {0.595f, 0.805f},
            {0.530f, 0.860f}, {0.515f, 0.335f}
        };

        for (int y = 0; y < h; y++)
        {
            float ny = (float)y / h;
            int row = y * stride;
            for (int x = 0; x < w; x++)
            {
                float nx = (float)x / w;
                int idx = row + x * 3;
                int b = pixels[idx];
                int g = pixels[idx + 1];
                int r = pixels[idx + 2];
                int max = Math.Max(r, Math.Max(g, b));
                int min = Math.Min(r, Math.Min(g, b));
                int sat = max - min;
                int lum = (r * 30 + g * 59 + b * 11) / 100;

                bool match = false;

                if (mode == "p1")
                {
                    if (PointInPoly(nx, ny, p1Poly) && lum > 135) match = true;
                }
                else if (mode == "p2")
                {
                    if (nx >= 0.538f && nx <= 0.738f && ny >= 0.125f && ny <= 0.510f)
                    {
                        bool isFace = (ny < 0.205f && r > 95 && (r - b) > 18);
                        bool isHand = (nx < 0.57f && ny > 0.48f && r > 105);
                        if (!isFace && !isHand && lum >= 16 && lum <= 105 && sat < 26) match = true;
                    }
                }
                else if (mode == "p3")
                {
                    if (nx >= 0.34f && nx <= 0.61f && ny >= 0.0f && ny <= 0.54f)
                    {
                        if (b >= r - 2 && lum < 115) match = true;
                    }
                }
                else if (mode == "p4")
                {
                    if (PointInPoly(nx, ny, p4Poly) && lum > 130) match = true;
                }
                else if (mode == "p5")
                {
                    if (PointInPoly(nx, ny, p5Poly))
                    {
                        bool isHand = (nx >= 0.37f && nx <= 0.435f && ny >= 0.22f && ny <= 0.35f && (r - b) > 45);
                        if (!isHand && lum > 95) match = true;
                    }
                }
                else if (mode == "w2")
                {
                    if (PointInPoly(nx, ny, w2Poly) && lum > 140) match = true;
                }
                else if (mode == "p8")
                {
                    if (nx >= 0.425f && nx <= 0.675f && ny >= 0.192f && ny <= 0.635f)
                    {
                        bool isTrousers = (ny > 0.545f && nx < 0.585f) || (ny > 0.555f && nx > 0.605f);
                        bool isSkin = (r > 125 && (r - b) > 28);
                        bool isWall = (lum > 115 && (r - b) > 16);
                        if (!isTrousers && !isSkin && !isWall && lum < 118) match = true;
                    }
                }
                else if (mode == "w4")
                {
                    if (nx >= 0.235f && nx <= 1.0f && ny >= 0.0f && ny <= 1.0f)
                    {
                        bool isNeckSkin = (nx >= 0.55f && nx <= 0.78f && ny <= 0.42f && (r - b) > 42);
                        bool isButton = (ny > 0.78f && lum < 75);
                        if (!isNeckSkin && !isButton && lum > 65) match = true;
                    }
                }
                else if (mode == "p6")
                {
                    if (PointInPoly(nx, ny, p6Poly) && (r - b) > 28 && lum < 210) match = true;
                }
                else if (mode == "c1")
                {
                    if (nx >= 0.23f && nx <= 0.485f && ny >= 0.355f && ny <= 0.89f)
                    {
                        if (lum > 135 && sat < 35) match = true;
                    }
                }
                else if (mode == "b1")
                {
                    if (nx >= 0.435f && nx <= 0.58f && ny >= 0.38f && ny <= 0.905f)
                    {
                        if ((r - b) >= 10 && lum >= 22 && lum <= 135) match = true;
                    }
                }
                else if (mode == "b2")
                {
                    if ((PointInPoly(nx, ny, b2Poly) || PointInPoly(nx, ny, b2PolyRight)) && lum < 165)
                    {
                        bool isJeans = (ny > 0.81f && b >= r - 4 && lum < 70);
                        if (!isJeans) match = true;
                    }
                }

                if (match) mask[y * w + x] = 1.0f;
            }
        }
        return mask;
    }

    private static float[] BlurMask(float[] mask, int w, int h, int radius)
    {
        float[] temp = new float[w * h];
        float[] output = new float[w * h];
        int diam = radius * 2 + 1;

        for (int y = 0; y < h; y++)
        {
            for (int x = 0; x < w; x++)
            {
                float sum = 0;
                for (int dx = -radius; dx <= radius; dx++)
                {
                    int nx = Math.Max(0, Math.Min(w - 1, x + dx));
                    sum += mask[y * w + nx];
                }
                temp[y * w + x] = sum / diam;
            }
        }
        for (int y = 0; y < h; y++)
        {
            for (int x = 0; x < w; x++)
            {
                float sum = 0;
                for (int dy = -radius; dy <= radius; dy++)
                {
                    int ny = Math.Max(0, Math.Min(h - 1, y + dy));
                    sum += temp[ny * w + x];
                }
                output[y * w + x] = sum / diam;
            }
        }
        return output;
    }
}
"@

Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing

[GarmentRecolorV2]::ProcessVariant("$imgDir\p1_base.jpg", "$imgDir\p1_obsidian.jpg", "p1", 32, 32, 30, 0.38, 1.35, 0.92)
[GarmentRecolorV2]::ProcessVariant("$imgDir\p1_base.jpg", "$imgDir\p1_olive.jpg", "p1", 92, 98, 76, 0.58, 1.25, 0.90)
[GarmentRecolorV2]::ProcessVariant("$imgDir\p1_base.jpg", "$imgDir\p1_oatmeal.jpg", "p1", 156, 134, 112, 0.72, 1.20, 0.88)

[GarmentRecolorV2]::ProcessVariant("$imgDir\p2_base.jpg", "$imgDir\p2_alabaster.jpg", "p2", 218, 210, 198, 2.35, 0.85, 0.92)
[GarmentRecolorV2]::ProcessVariant("$imgDir\p2_base.jpg", "$imgDir\p2_espresso.jpg", "p2", 82, 54, 38, 1.15, 1.15, 0.90)

[GarmentRecolorV2]::ProcessVariant("$imgDir\p3_base.jpg", "$imgDir\p3_black.jpg", "p3", 30, 30, 32, 0.85, 1.15, 0.92)

[GarmentRecolorV2]::ProcessVariant("$imgDir\p4_base.jpg", "$imgDir\p4_black.jpg", "p4", 30, 32, 34, 0.36, 1.35, 0.92)
[GarmentRecolorV2]::ProcessVariant("$imgDir\p4_base.jpg", "$imgDir\p4_sage.jpg", "p4", 138, 158, 120, 0.68, 1.20, 0.90)

[GarmentRecolorV2]::ProcessVariant("$imgDir\p5_base.jpg", "$imgDir\p5_obsidian.jpg", "p5", 32, 32, 30, 0.42, 1.30, 0.92)
[GarmentRecolorV2]::ProcessVariant("$imgDir\p5_base.jpg", "$imgDir\p5_ivory.jpg", "p5", 242, 238, 230, 1.18, 0.95, 0.88)

[GarmentRecolorV2]::ProcessVariant("$imgDir\w2_base.jpg", "$imgDir\w2_black.jpg", "w2", 32, 32, 32, 0.38, 1.35, 0.92)
[GarmentRecolorV2]::ProcessVariant("$imgDir\w2_base.jpg", "$imgDir\w2_taupe.jpg", "w2", 125, 114, 104, 0.64, 1.20, 0.90)

[GarmentRecolorV2]::ProcessVariant("$imgDir\p8_base.jpg", "$imgDir\p8_bone.jpg", "p8", 222, 215, 202, 2.25, 0.90, 0.90)

[GarmentRecolorV2]::ProcessVariant("$imgDir\w4_base.jpg", "$imgDir\w4_slate.jpg", "w4", 46, 52, 58, 0.48, 1.25, 0.90)

[GarmentRecolorV2]::ProcessVariant("$imgDir\p6_base.jpg", "$imgDir\p6_espresso.jpg", "p6", 68, 44, 30, 0.62, 1.20, 0.90)
[GarmentRecolorV2]::ProcessVariant("$imgDir\p6_base.jpg", "$imgDir\p6_black.jpg", "p6", 28, 28, 28, 0.48, 1.25, 0.92)

[GarmentRecolorV2]::ProcessVariant("$imgDir\c1_base.jpg", "$imgDir\c1_grey.jpg", "c1", 124, 122, 116, 0.68, 1.15, 0.90)
[GarmentRecolorV2]::ProcessVariant("$imgDir\c1_base.jpg", "$imgDir\c1_obsidian.jpg", "c1", 34, 34, 32, 0.42, 1.30, 0.92)

[GarmentRecolorV2]::ProcessVariant("$imgDir\b1_base.jpg", "$imgDir\b1_black.jpg", "b1", 26, 26, 26, 0.68, 1.20, 0.92)
[GarmentRecolorV2]::ProcessVariant("$imgDir\b1_base.jpg", "$imgDir\b1_oatmeal.jpg", "b1", 208, 200, 184, 2.15, 0.90, 0.90)

[GarmentRecolorV2]::ProcessVariant("$imgDir\b2_base.jpg", "$imgDir\b2_flax.jpg", "b2", 212, 198, 180, 1.85, 0.95, 0.88)
[GarmentRecolorV2]::ProcessVariant("$imgDir\b2_base.jpg", "$imgDir\b2_slate.jpg", "b2", 42, 54, 62, 0.72, 1.20, 0.90)

Write-Host "V2 garment variants generated successfully!"

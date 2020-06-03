


#include "RGB_FLOAT_HSL.h"

#define max(a,b,c) ((a > ((b>c)?b:c)) ? a : ((b>c)?b:c))
#define min(a,b,c) ((a < ((b<c)?b:c)) ? a : ((b<c)?b:c))

double Hue_2_RGB (double v1, double v2, double vH);

// RGB from 0 to 255; HSL results from 0 to 240
void RGBtoHSL(RGB_t *rgb, HSL_t *hsl)
{
	// 转到RGB(1, 1, 1)的空间
    double var_R = rgb->R / RGBMAX;
    double var_G = rgb->G / RGBMAX;
    double var_B = rgb->B / RGBMAX;

    double vmin = min(var_R, var_G, var_B);
    double vmax = max(var_R, var_G, var_B);
    double delta = vmax - vmin;

    double dr, dg, db;

	hsl->L = (vmax+vmin) / 2;

	if (0 == delta)
    {
        hsl->H = 0;
        hsl->S = 0;
    }
    else
    {
        if (hsl->L < 0.5) {
			hsl->S = delta / (vmax+vmin);
		} else {
			hsl->S = delta / (2-vmax-vmin);
		}
        dr = (((vmax-var_R)/6) + (delta/2))/delta;
        dg = (((vmax-var_G)/6) + (delta/2))/delta;
        db = (((vmax-var_B)/6) + (delta/2))/delta;

        if (var_R == vmax) {
			hsl->H = db - dg;
		} else if (var_G == vmax) {
			hsl->H = (1.0/3.0) + dr - db;
		} else if (var_B == vmax) {
			hsl->H = (2.0/3.0) + dg - dr;
		}

        if (hsl->H < 0) {
			hsl->H += 1;
		}
        if (hsl->H > 1) {
			hsl->H -= 1;
		}
    }

    // 转回到HSL(240, 240, 240)的空间
    hsl->H *= HSLMAX;
    hsl->S *= HSLMAX;
    hsl->L *= HSLMAX;
}

double Hue_2_RGB (double v1, double v2, double vH)
{
	if (vH < 0)
		vH += 1;
    if (vH > 1)
		vH -= 1;

    if ((6*vH) < 1)
        return (v1 + (v2-v1)*6*vH);
    if ((2*vH) < 1)
        return v2;
    if ((3*vH) < 2)
        return (v1 + (v2-v1)*((2.0/3.0)-vH)*6);

    return v1;
}

// HSL from 0 to 240; RGB results from 0 to 255
void HSLtoRGB(HSL_t *hsl, RGB_t *rgb)
{
    double v1, v2;

    // 转到HSL(1, 1, 1)的空间
	hsl->H /= HSLMAX;
	hsl->S /= HSLMAX;
	hsl->L /= HSLMAX;

	if(0 == hsl->S) {
		// 转回到RGB(255, 255, 255)的空间
		rgb->R = hsl->L * RGBMAX;
		rgb->G = hsl->L * RGBMAX;
		rgb->B = hsl->L * RGBMAX;
	} else {
		if(hsl->L < 0.5) {
			v2 = hsl->L * (1+hsl->S);
		} else {
			v2 = (hsl->L+hsl->S) - (hsl->L*hsl->S);
		}

		v1 = 2 * hsl->L - v2;

		// 转回到RGB(255, 255, 255)的空间
		rgb->R = RGBMAX * Hue_2_RGB (v1, v2, hsl->H+(1.0/3.0));
        rgb->G = RGBMAX * Hue_2_RGB (v1, v2, hsl->H);
        rgb->B = RGBMAX * Hue_2_RGB (v1, v2, hsl->H-(1.0/3.0));

	}

}


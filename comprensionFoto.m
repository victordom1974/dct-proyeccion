% comprensionFoto.m -- Orthogonal projection of an image vector onto the span of its k
% largest DCT coordinates. Grayscale (a vector of R^N) or colour (R, G and B stacked
% into ONE vector of R^(3N)). All vectors drawn "bar-style".
% Last modified: 2026-10-10
%
% Change log
%   2026-10-04  Merges bestk_dct_bars.m (grayscale) and bestk_dct_rgb.m (colour) into one
%               script: the two differed only in the number of channels. The image file
%               is chosen with uigetfile and the mode (grayscale / colour) with a dialog.
%               Everything else is as before: bar-style panels built by binning (bar()
%               cannot draw millions of entries), coordinates shown both in basis order
%               and sorted by magnitude, the cut shown as a vertical line on the sorted
%               coordinates and as a horizontal threshold in basis order, and a separate
%               figure comparing original and reconstruction side by side.
%   2026-10-10  Prepared for MATLAB Online (shared through GitHub): header name now
%               matches the file name; a console prompt before the pause, since in
%               MATLAB Online it is easy to miss that the script is waiting for a key.
%
% Requires Image Processing Toolbox (rgb2gray, dct2, idct2, imshow). MATLAB R2021+.

clear; close all; clc

nb   = 4000;                       % bins per channel segment when drawing
rgb  = [0.85 0.2 0.2; 0.2 0.6 0.2; 0.2 0.3 0.85];     % colours of the R, G, B segments
grey1 = [0.2 0.4 0.6];             % colour of the single segment in grayscale mode
orng = [0.9 0.5 0.1];  grey = [0.8 0.8 0.8];

%% Pick the image file
[fname, fpath] = uigetfile({'*.jpg;*.jpeg;*.tif;*.tiff;*.bmp', ...
                            'Image files (*.jpg,  *.tif, *.bmp)'; ...
                            '*.*', 'All files'}, 'Choose an image');
if isequal(fname, 0), fprintf('Cancelled.\n'); return, end
imgfile = fullfile(fpath, fname);

%% Pick the mode
mode = questdlg('Analyse the image as...', 'Mode', ...
                'Grayscale', 'Colour (R, G, B)', 'Grayscale');
if isempty(mode), fprintf('Cancelled.\n'); return, end
colour = strcmp(mode, 'Colour (R, G, B)');

%% 1. Image
X = double(imread(imgfile));
if colour
    if ndims(X) == 2, X = repmat(X, 1, 1, 3); end      % grey file asked for in colour
else
    if ndims(X) == 3, X = double(rgb2gray(uint8(X))); end
end
[m, n, nc] = size(X);
N    = m * n;                      % pixels per channel
Ntot = nc * N;                     % length of the image vector
seg  = @(c) (c-1)*N + (1:N);       % indices of channel c inside the long vector
col  = {grey1; rgb(1,:); rgb(2,:); rgb(3,:)};         % col{1} grey, col{2:4} R,G,B
cc   = @(c) col{1 + (nc==3)*c};                       % segment colour
xlab = 'Pixel index';  if colour, xlab = 'Index (R | G | B)'; end

% Comparison figure: original now on the left, reconstruction later on the right
cmp = figure('Name', 'Original vs reconstruction', 'Position', [100 100 1600 650]);
subplot(1,2,1); imshow(uint8(X));
title(sprintf('%s  --  original (%dx%d%s)', fname, m, n, repmat('x3', 1, colour)), ...
      'Interpreter', 'none');
drawnow

fprintf('Press any key (with the Command Window active) to continue...\n');
pause

fig = figure('Name', 'Orthogonal projection of the image vector', 'Position', [50 50 1600 800]);
t = tiledlayout(2, 4, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile(1); imshow(panelimg(X, colour));
if colour
    title(sprintf('1. Channels R, G, B (%dx%d each)', m, n));
else
    title(sprintf('1. Image M (%dx%d)', m, n));
end
drawnow

%% 2. The image vector
x = X(:);
nexttile(2); hold on
for c = 1:nc, barlike(x(seg(c)), nb, cc(c), (c-1)*N); end
hold off; xlim([0 Ntot+1]); ylim([0 255]);
if colour
    title(sprintf('2. Vector x = [vec(R); vec(G); vec(B)],  3N = %d', Ntot));
else
    title(sprintf('2. Vector x = vec(M),  N = %d', Ntot));
end
xlabel(xlab); ylabel('Grey level');
drawnow

%% 3. Coordinates in the DCT basis (magnitude, log scale, basis order)
Y = zeros(m, n, nc);
for c = 1:nc, Y(:,:,c) = dct2(X(:,:,c)); end
y = Y(:);  ay = abs(y);
ysort = sort(ay, 'descend');
fl = max(min(ysort(ysort > 0)), ysort(1) * 1e-9);     % floor of the log scale
yl = [fl, 2*ysort(1)];
nexttile(3); hold on
for c = 1:nc, barlike_log(ay(seg(c)), nb, cc(c), fl, (c-1)*N); end
hold off; xlim([0 Ntot+1]); ylim(yl);
title('3. Coordinates |y_i| in the DCT basis (basis order)');
xlabel('Basis index');
drawnow

%% 4. The same coordinates, sorted in decreasing order
nexttile(4); barlike_log(ysort, nb, orng, fl, 0);
xlim([0 Ntot+1]); ylim(yl);
title('4. The same |y_i|, sorted in decreasing order');
xlabel('Position after sorting');
drawnow

%% --- With the coordinates on screen, decide how many to keep ---
p = 0.05;
answer = inputdlg({'Percentage of coefficients to keep (e.g. 5):'}, ...
                  'Cut', [1 50], {num2str(100*p)});
if ~isempty(answer)
    q = str2double(answer{1}) / 100;
    if ~isnan(q) && q > 0 && q <= 1, p = q; end
end
k   = max(1, round(Ntot * p));
thr = ysort(k);                                       % threshold: k-th largest magnitude
figure(fig);

%% 5. Cut on the sorted coordinates: the first k survive (grey = cancelled)
[~, idx] = maxk(ay, k);
yk = zeros(Ntot, 1);  yk(idx) = y(idx);
nexttile(5); hold on
barlike_log(ysort, nb, grey, fl, 0);
barlike_log(ysort(1:k), nb, orng, fl, 0);
xline(k, 'k--', sprintf('k = %d', k), 'LabelOrientation', 'horizontal');
hold off; xlim([0 Ntot+1]); ylim(yl); set(gca, 'YScale', 'log');
title(sprintf('5. Cut: %d coordinates survive (%.2f%%)', k, 100*k/Ntot));
xlabel('Position after sorting');
drawnow

%% 6. The survivors, in basis order: whatever rises above the threshold
nexttile(6); hold on
for c = 1:nc
    barlike_log(ay(seg(c)), nb, grey, fl, (c-1)*N);
    barlike_log(ay(seg(c)), nb, cc(c), thr, (c-1)*N);
end
yline(thr, 'k--', sprintf('|y|_{(k)} = %.3g', thr), 'LabelHorizontalAlignment', 'left');
hold off; xlim([0 Ntot+1]); ylim(yl); set(gca, 'YScale', 'log');
title('6. Surviving coordinates (basis order)');
xlabel('Basis index');
drawnow

%% 7. Projected vector
Yk = reshape(yk, m, n, nc);
Xk = zeros(m, n, nc);
for c = 1:nc, Xk(:,:,c) = idct2(Yk(:,:,c)); end
xk = Xk(:);
rel_err = norm(x - xk) / norm(x);
psnr_dB = 20*log10(255 / sqrt(mean((x - xk).^2)));
nexttile(7); hold on
for c = 1:nc, barlike(xk(seg(c)), nb, cc(c), (c-1)*N); end
hold off; xlim([0 Ntot+1]); ylim([0 255]);
title('7. Projected vector P_k x');
xlabel(xlab); ylabel('Grey level');

%% 8. Reconstruction, here and in the comparison figure
nexttile(8); imshow(panelimg(Xk, colour));
if colour
    title(sprintf('8. Reconstructed channels (PSNR %.1f dB)', psnr_dB));
else
    title(sprintf('8. Reconstructed image M_k (PSNR %.1f dB)', psnr_dB));
end
title(t, sprintf('%s  --  k = %d of %d coefficients (%.2f%%)   |   relative error %.4f', ...
      mode, k, Ntot, 100*k/Ntot, rel_err));

figure(cmp);
subplot(1,2,2); imshow(uint8(Xk));
title(sprintf('Reconstruction:  %d of %d coefficients (%.2f%%),  PSNR %.1f dB', ...
      k, Ntot, 100*k/Ntot, psnr_dB));

%% Console report
mask = true(Ntot,1); mask(idx) = false;
fprintf('%s, %s mode:  %dx%d, %d coordinates\n', fname, lower(mode), m, n, Ntot);
fprintf('k = %d (%.2f%%).  Threshold |y|_(k) = %.4g\n', k, 100*k/Ntot, thr);
if colour
    kc = histcounts(idx, [0 N 2*N 3*N] + 0.5);
    fprintf('Survivors per channel:  R %d (%.2f%%)   G %d (%.2f%%)   B %d (%.2f%%)\n', ...
            kc(1), 100*kc(1)/N, kc(2), 100*kc(2)/N, kc(3), 100*kc(3)/N);
end
fprintf('Relative error %.4f, PSNR %.1f dB\n', rel_err, psnr_dB);
fprintf('Parseval: ||x-xk|| = %.6e,  ||discarded y|| = %.6e\n', norm(x-xk), norm(y(mask)));

%% ---------------------------------------------------------------------------
function T = panelimg(X, colour)
% In colour mode, the three channels stacked vertically, each tinted with its own
% colour and separated by thin white gaps; in grayscale mode, the image itself.
if ~colour, T = uint8(X); return, end
[m, n, ~] = size(X);
gap = 255 * ones(max(1, round(0.02*m)), n, 3);
chan = cell(1, 3);
for c = 1:3
    chan{c} = zeros(m, n, 3);  chan{c}(:,:,c) = X(:,:,c);
end
T = uint8([chan{1}; gap; chan{2}; gap; chan{3}]);
end

function barlike(v, nb, c, x0)
% Draws v "bar-style from zero" (linear scale), shifted by x0 along the x axis.
% For long v, nb bins, each filled from 0 up to its maximum (and down to its minimum).
v = v(:);  N = numel(v);
if N <= nb
    bar(x0 + (1:N), v, 1, 'FaceColor', c, 'EdgeColor', 'none');
else
    bin = ceil((1:N)' * nb / N);
    hi  = max(0, accumarray(bin, v, [nb 1], @max));
    lo  = min(0, accumarray(bin, v, [nb 1], @min));
    xc  = x0 + ((0:nb-1)' + 0.5) * N / nb;
    fill([xc; flipud(xc)], [hi; flipud(lo)], c, 'EdgeColor', 'none');
end
end

function barlike_log(v, nb, c, base, x0)
% Same as barlike for v >= 0 on a log scale: bars from 'base' up to each bin's maximum.
v = max(v(:), base);  N = numel(v);
if N <= nb
    bar(x0 + (1:N), v, 1, 'FaceColor', c, 'EdgeColor', 'none', 'BaseValue', base);
else
    bin = ceil((1:N)' * nb / N);
    hi  = accumarray(bin, v, [nb 1], @max);
    xc  = x0 + ((0:nb-1)' + 0.5) * N / nb;
    fill([xc; flipud(xc)], [hi; base*ones(nb,1)], c, 'EdgeColor', 'none');
end
set(gca, 'YScale', 'log');
end
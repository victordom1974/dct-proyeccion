% dct_basis_bars.m -- The 2D DCT basis of an m x n block, drawn one vector at a time:
% first as little images, then as what they really are, vectors of R^(m*n).
% Last modified: 2026-10-04
%
% Change log
%   2026-10-04  First version. Companion to bestk_dct_bars.m / bestk_dct_rgb.m: those
%               show the coordinates, this one shows WHAT they are coordinates of.
%               The basis vectors are obtained as idct2 of the canonical matrices E_ij,
%               so they are literally the basis that dct2 uses (no formula retyped).
%   2026-10-04  Block size 9x6. Second figure: the same basis drawn as vectors, each
%               B{i,j}(:) as a bar plot of m*n entries, with dotted separators between
%               the n column-blocks (columns are stacked by vec, and the n blocks are
%               the same vertical profile scaled by the horizontal cosine: the basis
%               is separable).
%   2026-10-04  Fixed cmax: cellfun over an m x n cell array returns an m x n matrix and
%               max() of a matrix works column-wise, so cmax came out as a row vector.
%   2026-10-04  Drawing speed: the panels were slow to build, not to compute. Figures are
%               built with 'Visible','off' and shown at the end (one repaint each); the
%               n-1 separators per panel are a single NaN-separated polyline instead of
%               xline objects; no yline (bar draws its own baseline).
%   2026-10-04  Portability target set at R2021 and later. Back to tiledlayout/nexttile
%               (tighter panels than subplot) and to title/subtitle on the layout; the
%               annotation-based banner is gone -- a textbox annotation has no
%               Interpreter property, which is what made it fail. Superscripts in titles
%               need braces: R^{54}, not R^54, or TeX takes only the first digit.
%               Renderer 'painters' is the software (vector) renderer: it needs no GPU.
%
% Requires Image Processing Toolbox (idct2)

clear; close all; clc

m = 8;  n = 6;                 % block size: m*n basis vectors
N = m * n;

%% ---- The basis ---------------------------------------------------------------
% B{i,j} = idct2(E_ij) with E_ij the canonical matrix: the (i,j) basis vector,
% oscillating i half-waves vertically and j half-waves horizontally.
B = cell(m, n);
for i = 1:m
    for j = 1:n
        E = zeros(m, n);  E(i, j) = 1;
        B{i,j} = idct2(E);
    end
end
cvals = cellfun(@(b) max(abs(b(:))), B);
cmax  = max(cvals(:));                       % common symmetric scale

%% ---- Figure 1: as little images ----------------------------------------------
f1 = figure('Name', 'DCT basis (as images)', 'Position', [60 60 760 1000], ...
    'Visible', 'off', 'Renderer', 'painters', 'Color', 'w');
t1 = tiledlayout(m, n, 'TileSpacing', 'compact', 'Padding', 'compact');
for i = 1:m
    for j = 1:n
        nexttile((i-1)*n + j);
        imagesc(B{i,j}, [-cmax cmax]); axis image off
        title(sprintf('(%d,%d)', i-1, j-1), 'FontSize', 8);
    end
end
colormap(gray);
title(t1, sprintf('The %d vectors of the DCT basis of a %dx%d block', N, m, n), ...
    'FontWeight', 'bold');
subtitle(t1, 'row index i = vertical frequency, column index j = horizontal frequency');

%% ---- Figure 2: as vectors of R^N ---------------------------------------------
% Same objects, now as v = B{i,j}(:): m*n numbers in a row. vec stacks the columns,
% so each vector shows n blocks of m entries; the n blocks are the same vertical
% profile scaled by the horizontal cosine (the basis is separable).
% The separators are ONE polyline per panel, its segments joined by NaN.
sepx = reshape(repmat((1:n-1)*m + 0.5, 3, 1), 1, []);
sepy = repmat([-1.1*cmax, 1.1*cmax, NaN], 1, n-1);

f2 = figure('Name', 'DCT basis (as vectors)', 'Position', [60 60 1500 950], ...
    'Visible', 'off', 'Renderer', 'painters', 'Color', 'w');
t2 = tiledlayout(m, n, 'TileSpacing', 'compact', 'Padding', 'compact');
for i = 1:m
    for j = 1:n
        ax = nexttile((i-1)*n + j);
        hold on
        bar(B{i,j}(:), 1, 'FaceColor', [0.2 0.4 0.6], 'EdgeColor', 'none');
        plot(sepx, sepy, ':', 'Color', [0.7 0.7 0.7]);
        hold off
        set(ax, 'XTick', [], 'YTick', [], 'Box', 'off', ...
            'XLim', [0.5 N+0.5], 'YLim', 1.1*[-cmax cmax]);
        title(sprintf('(%d,%d)', i-1, j-1), 'FontSize', 8);
    end
end
title(t2, sprintf('The same %d vectors, as vectors of R^{%d}:  v = B(:)', N, N), ...
    'FontWeight', 'bold');
subtitle(t2, sprintf('vec stacks the %d columns; dotted lines separate them', n));

set([f1 f2], 'Visible', 'on');     % one repaint each, at the end

%% ---- Orthonormality check ------------------------------------------------------
% The Gram matrix of the N basis vectors is the identity.
Q = zeros(N, N);
for i = 1:m
    for j = 1:n, Q(:, (j-1)*m + i) = reshape(B{i,j}, [], 1); end
end
D = abs(Q'*Q - eye(N));
fprintf('Basis %dx%d:  max |Q''Q - I| = %.2e   (orthonormal)\n', m, n, max(D(:)));
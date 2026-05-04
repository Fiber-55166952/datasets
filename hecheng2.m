clear; clc; close all;
rng(1);   % 固定随机种子，便于复现

% 保存目录：改成你自己的 use_data 路径
save_path = 'E:\Second Grade\Part Four\algrithm_test_4_13\demo_standard\Databases\numberical_datasets\hecheng_data';

if ~exist(save_path, 'dir')
    mkdir(save_path);
end

types = { ...
    'TwoMoons', ...
    'CircleBlob', ...
    'SwissRoll', ...
    'ConcentricCircles', ...
    'AudiRings', ...
    'OlympicRings', ...
    'KArtificial3D', ...
    'TwoArmsSpiral', ...
    'ThreeArmsSpiral', ...
    'FiveInterlockedRings3D', ...
    'TwinSameLoops2D'};

for k = 1:length(types)
    [X, labels, title_str] = generate_classic_manifold(types{k});

    % 每行一个样本，最后一列是标签
    data_to_save = [X, labels];
    file_name = fullfile(save_path, [types{k}, '.xlsx']);
    writematrix(data_to_save, file_name);

    fprintf('已生成: %s\n', file_name);

    % ---------------- 可视化检查 ----------------
    figure('Color','w','Name',types{k});

    if strcmp(types{k}, 'FiveInterlockedRings3D')
        % 颜色顺序：
        % 1橙(左, xz) 2绿(前, yz) 3蓝(中, xy) 4紫(后, yz) 5红(右, xz)
        cmap5 = [ ...
            0.90 0.58 0.12;   % 橙
            0.40 0.85 0.40;   % 绿
            0.10 0.50 0.90;   % 蓝
            0.35 0.15 0.85;   % 紫
            0.88 0.10 0.10];  % 红

        hold on;
        for c = 1:5
            idx = labels == c;
            scatter3(X(idx,1), X(idx,2), X(idx,3), 10, ...
                repmat(cmap5(c,:), sum(idx), 1), 'filled');
        end
        hold off;
        grid on;
        axis equal;
        axis vis3d;
        view(28, 16);

    elseif strcmp(types{k}, 'TwinSameLoops2D')
        % 颜色顺序：1红 2紫
        cmap2 = [ ...
            0.88 0.10 0.10;   % 红
            0.45 0.20 0.85];  % 紫

        hold on;
        for c = 1:2
            idx = labels == c;
            scatter(X(idx,1), X(idx,2), 10, ...
                repmat(cmap2(c,:), sum(idx), 1), 'filled');
        end
        hold off;
        grid on;
        axis equal;

    elseif size(X,2) == 2
        gscatter(X(:,1), X(:,2), labels);
        axis equal;
        grid on;

    elseif size(X,2) == 3
        scatter3(X(:,1), X(:,2), X(:,3), 10, labels, 'filled');
        grid on;
        axis equal;
        axis vis3d;
        view(35, 20);
    end

    title(title_str);
    drawnow;
end

disp('所有合成数据集已全部保存完成。');


function [X, labels, title_str] = generate_classic_manifold(type)
    N = 600;
    noise_level = 0.05;

    switch type
        case 'TwoMoons'
            title_str = 'Interleaved Moons';
            n_samples = floor(N/2);
            t = linspace(0, pi, n_samples)';
            x1 = [cos(t), sin(t)];
            x2 = [1 - cos(t), 0.5 - sin(t)];
            X = [x1; x2];
            X = X + noise_level * randn(size(X));
            labels = [ones(n_samples, 1); 2 * ones(n_samples, 1)];

        case 'CircleBlob'
            title_str = 'Circle with Blob';
            n_samples_outer = floor(N * 0.7);
            n_samples_inner = N - n_samples_outer;
            t = linspace(0, 2*pi, n_samples_outer+1)';
            t(end) = [];
            r = 1 + noise_level * randn(n_samples_outer, 1);
            x1 = [r .* cos(t), r .* sin(t)];
            x2 = noise_level * 2 * randn(n_samples_inner, 2);
            X = [x1; x2];
            labels = [ones(n_samples_outer, 1); 2 * ones(n_samples_inner, 1)];

        case 'SwissRoll'
            title_str = 'Swiss Roll (Two Spirals)';
            n_samples = floor(N/2);
            theta = linspace(0, 4*pi, n_samples)';
            r = theta;
            x1 = [r .* cos(theta), r .* sin(theta)];
            x2 = [-r .* cos(theta), -r .* sin(theta)];
            X = [x1; x2];
            X = X + noise_level * randn(size(X));
            labels = [ones(n_samples, 1); 2 * ones(n_samples, 1)];

        case 'ConcentricCircles'
            title_str = 'Three Concentric Circles';
            n_per_ring = floor(N/3);
            r1 = 0.2; r2 = 0.5; r3 = 0.9;
            X = []; labels = [];
            t = linspace(0, 2*pi, n_per_ring+1)';
            t(end) = [];

            noise = noise_level * 0.5 * randn(n_per_ring, 1);
            X = [X; [(r1+noise).*cos(t), (r1+noise).*sin(t)]];
            labels = [labels; 1 * ones(n_per_ring, 1)];

            noise = noise_level * 0.5 * randn(n_per_ring, 1);
            X = [X; [(r2+noise).*cos(t), (r2+noise).*sin(t)]];
            labels = [labels; 2 * ones(n_per_ring, 1)];

            noise = noise_level * 0.5 * randn(n_per_ring, 1);
            X = [X; [(r3+noise).*cos(t), (r3+noise).*sin(t)]];
            labels = [labels; 3 * ones(n_per_ring, 1)];

        case 'AudiRings'
            title_str = 'Audi Rings';
            n_per_ring = floor(N / 4);
            ring_radius = 0.35;
            gap = 0.55;

            centers = [0,      0;
                       gap,    0;
                       2*gap,  0;
                       3*gap,  0];

            X = [];
            labels = [];
            t = linspace(0, 2*pi, n_per_ring+1)';
            t(end) = [];

            for i = 1:4
                noise = noise_level * 0.4 * randn(n_per_ring, 1);
                r = ring_radius + noise;
                cx = centers(i,1);
                cy = centers(i,2);

                xi = [cx + r .* cos(t), cy + r .* sin(t)];
                X = [X; xi];
                labels = [labels; i * ones(n_per_ring, 1)];
            end

        case 'OlympicRings'
            title_str = 'Olympic Rings';
            n_per_ring = floor(N / 5);
            ring_radius = 0.23;

            centers = [ ...
                -0.55,  0.12;
                 0.00,  0.14;
                 0.55,  0.16;
                -0.28, -0.12;
                 0.28, -0.10];

            X = [];
            labels = [];
            t = linspace(0, 2*pi, n_per_ring+1)';
            t(end) = [];

            for i = 1:5
                radial_noise = 0.010 * randn(n_per_ring,1);
                point_noise  = 0.003 * randn(n_per_ring,2);
                r = ring_radius + radial_noise;

                xi = [centers(i,1) + r.*cos(t), ...
                      centers(i,2) + r.*sin(t)] + point_noise;

                X = [X; xi];
                labels = [labels; i * ones(n_per_ring,1)];
            end

        case 'KArtificial3D'
            title_str = 'K-Artificial 3D';
            n1 = floor(N/2);
            n2 = N - n1;

            % 蓝色薄片
            u1 = [1.0, 0.18, 0.10];
            u1 = u1 / norm(u1);
            v1 = [0.10, 0.35, 1.00];
            v1 = v1 / norm(v1);

            a1 = 8.5 * (rand(n1,1) - 0.5);
            b1 = 1.1 * (rand(n1,1) - 0.5);
            X1 = a1 .* u1 + b1 .* v1 + 0.06 * randn(n1,3);

            % 红色薄片
            u2 = [0.12, 1.00, 0.18];
            u2 = u2 / norm(u2);
            v2 = [1.00, -0.08, 0.28];
            v2 = v2 / norm(v2);

            a2 = 6.8 * (rand(n2,1) - 0.5);
            b2 = 0.9 * (rand(n2,1) - 0.5);
            X2 = a2 .* u2 + b2 .* v2 + 0.06 * randn(n2,3);

            X = [X1; X2];
            labels = [ones(n1,1); 2*ones(n2,1)];

            Rx = [1 0 0;
                  0 cosd(16) -sind(16);
                  0 sind(16)  cosd(16)];
            Rz = [cosd(18) -sind(18) 0;
                  sind(18)  cosd(18) 0;
                  0         0        1];
            X = X * Rx' * Rz';

        case 'TwoArmsSpiral'
            title_str = 'Two-Arms Pinwheel';
            offsets = [-0.10, pi/2 - 0.10];

            [X, labels] = generate_full_pinwheel( ...
                offsets, ...
                N, ...
                1.85, ...
                0.72, ...
                0.08, ...
                0.040, ...
                0.015);

        case 'ThreeArmsSpiral'
            title_str = 'Three-Arms Pinwheel';
            base_rot = 0.32;
            offsets = [base_rot, base_rot + 2*pi/3, base_rot + 4*pi/3];

            [X, labels] = generate_full_pinwheel( ...
                offsets, ...
                N, ...
                1.78, ...
                0.60, ...
                0.08, ...
                0.038, ...
                0.015);

        % 第一幅图：五个三维互锁环
        % 1橙(左, xz) 2绿(前, yz) 3蓝(中, xy) 4紫(后, yz) 5红(右, xz)
        case 'FiveInterlockedRings3D'
            title_str = 'Five Interlocked Rings 3D';
            [X, labels] = generate_five_interlocked_rings_3d(N);

        % 第二幅图：两个相同的二维图形
        case 'TwinSameLoops2D'
            title_str = 'Twin Same Loops 2D';
            [X, labels] = generate_twin_same_loops_2d(N);

        otherwise
            error('未知数据集类型：%s', type);
    end
end


function [X, labels] = generate_full_pinwheel(offsets, N, t_max, a1, a2, width_noise, t_jitter)
    K = numel(offsets);
    n_per_class = floor(N / K);

    X = [];
    labels = [];

    for k = 1:K
        t = linspace(-t_max, t_max, n_per_class)';
        t = t + t_jitter * randn(n_per_class,1);
        t = max(min(t, t_max), -t_max);
        t = sort(t);

        r = abs(t);
        theta = offsets(k) + a1 * r + a2 * (r.^2);

        x0 = t .* cos(theta);
        y0 = t .* sin(theta);

        sgn = sign(t);
        sgn(sgn == 0) = 1;
        dtheta_dt = (a1 + 2*a2*r) .* sgn;

        dx_dt = cos(theta) - t .* sin(theta) .* dtheta_dt;
        dy_dt = sin(theta) + t .* cos(theta) .* dtheta_dt;

        norm_tangent = sqrt(dx_dt.^2 + dy_dt.^2) + eps;
        nx = -dy_dt ./ norm_tangent;
        ny =  dx_dt ./ norm_tangent;

        w = width_noise * randn(n_per_class,1);
        x = x0 + w .* nx;
        y = y0 + w .* ny;

        Xi = [x, y];
        X = [X; Xi];
        labels = [labels; k * ones(n_per_class, 1)];
    end
end


function [X, labels] = generate_five_interlocked_rings_3d(N)
    % 正确空间关系：
    % 1 橙：左，在 x-z 面
    % 2 绿：前，在 y-z 面
    % 3 蓝：中，在 x-y 面（水平环）
    % 4 紫：后，在 y-z 面
    % 5 红：右，在 x-z 面

    n1 = floor(N/5);
    n2 = floor(N/5);
    n3 = floor(N/5);
    n4 = floor(N/5);
    n5 = N - n1 - n2 - n3 - n4;

    % 左边橙色环：x-z 面（y 为常数）
    X1 = sample_ring_xz([-1.28, 0.00, 0.00], 0.72, 1.52, n1, 0.016);

    % 前边绿色环：y-z 面（x 为常数）
    X2 = sample_ring_yz([0.00, -0.82, 0.00], 0.58, 1.55, n2, 0.016);

    % 中间蓝色环：x-y 面（z 为常数）——水平环
    X3 = sample_ring_xy([0.00, 0.00, 0.00], 1.32, 0.98, n3, 0.016);

    % 后边紫色环：y-z 面（x 为常数）
    X4 = sample_ring_yz([0.00, 0.82, 0.00], 0.58, 1.55, n4, 0.016);

    % 右边红色环：x-z 面（y 为常数）
    X5 = sample_ring_xz([1.28, 0.00, 0.00], 0.74, 1.55, n5, 0.016);

    X = [X1; X2; X3; X4; X5];
    labels = [ ...
        1*ones(n1,1); ...
        2*ones(n2,1); ...
        3*ones(n3,1); ...
        4*ones(n4,1); ...
        5*ones(n5,1)];
end


function X = sample_ring_xy(center, Rx, Ry, n, sigma)
    t = linspace(0, 2*pi, n+1)';
    t(end) = [];
    x = center(1) + Rx*cos(t);
    y = center(2) + Ry*sin(t);
    z = center(3) + zeros(size(t));
    X = [x, y, z] + sigma * randn(n,3);
end


function X = sample_ring_yz(center, Ry, Rz, n, sigma)
    t = linspace(0, 2*pi, n+1)';
    t(end) = [];
    x = center(1) + zeros(size(t));
    y = center(2) + Ry*cos(t);
    z = center(3) + Rz*sin(t);
    X = [x, y, z] + sigma * randn(n,3);
end


function X = sample_ring_xz(center, Rx, Rz, n, sigma)
    t = linspace(0, 2*pi, n+1)';
    t(end) = [];
    x = center(1) + Rx*cos(t);
    y = center(2) + zeros(size(t));
    z = center(3) + Rz*sin(t);
    X = [x, y, z] + sigma * randn(n,3);
end


function [X, labels] = generate_twin_same_loops_2d(N)
    % 两个完全相同的二维图形
    % 单个图形形状保持不变，只调整二者的相对位置
    %
    % 正确位置关系：
    % - 两个图形水平一致（y方向基本相同）
    % - 仅在x方向稍微错开
    % - 红色略偏左，紫色略偏右

    n1 = floor(N/2);
    n2 = N - n1;

    % 单个原始形状保持不变
    base1 = make_new_handdrawn_loop_2d(n1);
    base2 = make_new_handdrawn_loop_2d(n2);

    % 只做左右错开，不做上下错开
    shift_red    = [-0.12,  0.00];
    shift_purple = [ 0.12,  0.00];

    X1 = base1 + repmat(shift_red,    size(base1,1), 1);   % 红色
    X2 = base2 + repmat(shift_purple, size(base2,1), 1);   % 紫色

    % 少量噪声形成点带
    X1 = X1 + 0.006 * randn(size(X1));
    X2 = X2 + 0.006 * randn(size(X2));

    X = [X1; X2];
    labels = [ones(n1,1); 2*ones(n2,1)];
end


function P = make_new_handdrawn_loop_2d(n)
    % 最新手绘图对应的二维单曲线：
    % 左尾 -> 交叉点(第一次) -> 沿左边上升 -> 绕顶部 ->
    % 沿右边下落 -> 回到交叉点(第二次) -> 向右伸出右尾
    %
    % 图形特征：
    % - 竖直细长主回环
    % - 底部单交叉
    % - 左右两条短尾巴
    % - 左右近似对称
    % - 整条线是开曲线

    ctrl = [ ...
        -1.10, -0.02;   % 左尾起点
        -0.98, -0.10;
        -0.78, -0.15;
        -0.52, -0.16;
        -0.26, -0.10;
         0.00,  0.00;   % 第一次到交叉点

        -0.14,  0.36;   % 沿左边上升
        -0.22,  0.82;
        -0.22,  1.24;
        -0.14,  1.56;
         0.00,  1.72;   % 顶部
         0.14,  1.56;
         0.22,  1.24;
         0.22,  0.82;
         0.14,  0.36;   % 沿右边下落

         0.00,  0.00;   % 第二次回到交叉点

         0.26, -0.10;   % 向右尾出去
         0.52, -0.16;
         0.78, -0.15;
         0.98, -0.10;
         1.10, -0.02];  % 右尾终点

    s = 1:size(ctrl,1);
    sq = linspace(1, size(ctrl,1), n)';

    x = interp1(s, ctrl(:,1), sq, 'pchip');
    y = interp1(s, ctrl(:,2), sq, 'pchip');

    P = [x, y];
end
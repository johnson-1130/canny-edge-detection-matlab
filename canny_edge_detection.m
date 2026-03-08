% 讀取圖像並轉換為灰度圖
I = imread('mickey.png'); %  'mickey.png' 是我用的圖片名，換別張圖片的話這邊要改
I_gray = rgb2gray(I);

% 顯示原始圖像
figure, imshow(I_gray), title('原始圖像');

% 應用高斯模糊濾波器進行噪聲去除
G = fspecial('gaussian', [5 5], 1.4);
I_smoothed = imfilter(I_gray, G, 'same');

% 顯示平滑後的圖像
figure, imshow(I_smoothed), title('高斯模糊後的圖像');

% 使用 Sobel 算子計算水平和垂直方向的梯度
[Gx, Gy] = imgradientxy(I_smoothed, 'sobel');

% 計算梯度強度和方向
[gradient_magnitude, gradient_direction] = imgradient(Gx, Gy);

% 顯示梯度強度圖像
figure, imshow(gradient_magnitude, []), title('梯度強度');

% 非最大抑制的實現
[rows, cols] = size(gradient_magnitude);
non_max_suppressed = zeros(rows, cols);

% 對每一個像素進行處理
for i = 2:rows-1
    for j = 2:cols-1
        angle = gradient_direction(i, j);
        
        % 確保角度在 0 到 180 度之間
        if angle < 0
            angle = angle + 180;
        end
        
        % 根據梯度方向決定檢查的像素點
        if ((angle >= 0 && angle < 22.5) || (angle >= 157.5 && angle <= 180))
            check1 = gradient_magnitude(i, j + 1);
            check2 = gradient_magnitude(i, j - 1);
        elseif (angle >= 22.5 && angle < 67.5)
            check1 = gradient_magnitude(i + 1, j - 1);
            check2 = gradient_magnitude(i - 1, j + 1);
        elseif (angle >= 67.5 && angle < 112.5)
            check1 = gradient_magnitude(i + 1, j);
            check2 = gradient_magnitude(i - 1, j);
        elseif (angle >= 112.5 && angle < 157.5)
            check1 = gradient_magnitude(i - 1, j - 1);
            check2 = gradient_magnitude(i + 1, j + 1);
        end
        
        % 只有當該像素點的梯度強度大於相鄰的兩個點時才保留
        if (gradient_magnitude(i, j) >= check1 && gradient_magnitude(i, j) >= check2)
            non_max_suppressed(i, j) = gradient_magnitude(i, j);
        else
            non_max_suppressed(i, j) = 0;
        end
    end
end

% 顯示非最大抑制後的圖像
figure, imshow(non_max_suppressed, []), title('非最大抑制後的圖像');

% 雙閾值檢測
low_threshold = 0.1 * max(max(non_max_suppressed));
high_threshold = 0.3 * max(max(non_max_suppressed));
edges = zeros(rows, cols);

% 強邊緣
strong_edge = non_max_suppressed >= high_threshold;

% 弱邊緣
weak_edge = non_max_suppressed >= low_threshold & non_max_suppressed < high_threshold;

% 將強邊緣設為 1
edges(strong_edge) = 1;

% 邊緣連接，將與強邊緣連接的弱邊緣也設為 1
for i = 2:rows-1
    for j = 2:cols-1
        if weak_edge(i, j)
            if (strong_edge(i + 1, j - 1) || strong_edge(i + 1, j) || strong_edge(i + 1, j + 1) || ...
                strong_edge(i, j - 1) || strong_edge(i, j + 1) || ...
                strong_edge(i - 1, j - 1) || strong_edge(i - 1, j) || strong_edge(i - 1, j + 1))
                edges(i, j) = 1;
            end
        end
    end
end

% 顯示最終邊緣檢測結果
figure, imshow(edges), title('Canny 邊緣檢測結果');

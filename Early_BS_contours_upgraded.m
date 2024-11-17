% Methode (avec les contours + direction) de la methode de Barnea et Silverman
% Fait par Gaspard Langlais

function detector(image, windowSize, baseThreshold)
    % Debut chrono
    tic;
    
    % Initialisation
    if size(image, 3) == 3
        image = rgb2gray(image);
    end
    image = double(image);
    contours = edge(image, 'Canny');
    [Gx, Gy] = gradient(image);
    halfWindow = floor(windowSize / 2);
    [rows, cols] = size(image);
    corners = zeros(rows, cols);
    
    % Gestion seuils
    scalingFactor = (windowSize^2) / (3^2); % Basé sur du 3x3
    threshold = baseThreshold * scalingFactor;
    thresholPartiel = linspace(threshold / windowSize^2, threshold, windowSize^2);
    
    % Boucle à travers l'image
    for i = (1 + halfWindow):(rows - halfWindow)
        for j = (1 + halfWindow):(cols - halfWindow)
            if contours(i, j) == 1
                angle = atan2(Gy(i, j), Gx(i, j));
                direction = 0; 
                
                % Direction selon l'angle
                if abs(angle) < pi/8
                    direction = 1; % Horizontal
                elseif abs(angle) > 3*pi/8
                    direction = 2; % Vertical
                elseif angle > 0
                    direction = 3; % Diagonale haut-gauche à bas-droite
                else
                    direction = 4; % Diagonale haut-droite à bas-gauche
                end
                
                % Gestion des sous fenetres
                if direction == 1
                    % Horizontale (gauche-droite)
                    patch1 = image(i-halfWindow:i+halfWindow, j-halfWindow:j);
                    patch2 = image(i-halfWindow:i+halfWindow, j:j+halfWindow);
                elseif direction == 2
                    % Verticale (haut-bas)
                    patch1 = image(i-halfWindow:i, j-halfWindow:j+halfWindow);
                    patch2 = image(i:i+halfWindow, j-halfWindow:j+halfWindow);
                elseif direction == 3
                    % Diagonale (haut gauche-bas droite)
                    patch1 = image(i-halfWindow:i, j-halfWindow:j);
                    patch2 = image(i:i+halfWindow, j:j+halfWindow);
                elseif direction == 4
                    % Diagonale (haut droite-bas gauche)
                    patch1 = image(i-halfWindow:i, j:j+halfWindow);
                    patch2 = image(i:i+halfWindow, j-halfWindow:j);
                end
                                        
                % Initialisation jumpOut
                diffSum = 0;
                jumpOut = false;
                randomIndices = randperm(numel(patch1));
                
                for k = 1:numel(patch1)
                    idx = randomIndices(k); 
                    diffSum = diffSum + abs(patch1(idx) - patch2(idx));
                    
                    % Jump-Out
                    if diffSum > thresholPartiel(k)
                        jumpOut = true;
                        break;
                    end
                end
                
                if jumpOut
                    corners(i, j) = 1;
                    break; % Si un coin est détecté dans une direction, inutile de tester les autres
                end
            end
        end
    end
    
    % Afficher le temps d'exécution
    elapsedTime = toc;
    fprintf('Temps d''exécution : %.4f secondes\n', elapsedTime);
    
    % Afficher l'image avec les contours détectés
    figure;
    imshow(contours);
    title('Contours via Canny');
    
    % Afficher image + coins
    figure;
    imshow(image, []);
    hold on;
    [y, x] = find(corners == 1);
    plot(x, y, 'r+', 'MarkerSize', 5, 'LineWidth', 1);
    title('Coins détectés avec Early Jump-Out sur les contours');
    hold off;
end

% Lancement
image = imread('Rainier1.png');
detector(image, 16, 1700); 

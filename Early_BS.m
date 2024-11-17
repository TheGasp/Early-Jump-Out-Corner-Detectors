% Methode basique (sans aucune amélioration) de la methode de Barnea et Silverman
% Fait par Gaspard Langlais

function detector(image, windowSize, baseThreshold)
    % Début chrono
    tic;
    
    % Initialisation
    if size(image, 3) == 3
        image = rgb2gray(image);
    end
    image = double(image);
    halfWindow = floor(windowSize / 2);
    [rows, cols] = size(image);
    corners = zeros(rows, cols);
    
    % Gestion seuils
    scalingFactor = (windowSize^2) / (3^2); % Basé sur du 3*3
    threshold = baseThreshold * scalingFactor;
    thresholPartiel = linspace(threshold / windowSize^2, threshold, windowSize^2);    

    % Boucle à travers l'image
    for i = (1 + halfWindow):(rows - halfWindow)
        for j = (1 + halfWindow):(cols - halfWindow)
            
            for direction = ["horizontal", "vertical", "diagonal1", "diagonal2"]
                if direction == "horizontal"
                    % Horizontale (gauche-droite)
                    patch1 = image(i-halfWindow:i+halfWindow, j-halfWindow:j);
                    patch2 = image(i-halfWindow:i+halfWindow, j:j+halfWindow);
                elseif direction == "vertical"
                    % Verticale (haut-bas)
                    patch1 = image(i-halfWindow:i, j-halfWindow:j+halfWindow);
                    patch2 = image(i:i+halfWindow, j-halfWindow:j+halfWindow);
                elseif direction == "diagonal1"
                    % Diagonale (haut gauche-bas droite)
                    patch1 = image(i-halfWindow:i, j-halfWindow:j);
                    patch2 = image(i:i+halfWindow, j:j+halfWindow);
                elseif direction == "diagonal2"
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
    
    % Afficher les temps 
    elapsedTime = toc;
    fprintf('Temps d''exécution : %.4f secondes\n', elapsedTime);
    
    % Afficher image + coins
    figure;
    imshow(image, []);
    hold on;
    [y, x] = find(corners == 1);
    plot(x, y, 'r+', 'MarkerSize', 5, 'LineWidth', 1);
    title('Coins détectés avec Early Jump-Out');
    hold off;
end

% Lancement
image = imread('Rainier1.png');
detector(image, 16, 1700);

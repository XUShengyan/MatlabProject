% 2017-05-22 by LSS
% Live Face Detection
% Need to manually install support package (OS Generic Video Interface)
vidDevice = imaq.VideoDevice('winvideo', 1, 'MJPG_320x240', ...
                             'ROI', [1 1 320 240], ...
                             'ReturnedColorSpace', 'rgb', ...
                             'DeviceProperties.Brightness', 8, ...
                             'DeviceProperties.Sharpness', 8);
hVideoIn = vision.VideoPlayer;
hVideoIn.Name  = 'Input Video';
hVideoOut = vision.VideoPlayer;
hVideoOut.Name  = 'Output Video';
faceDetector = vision.CascadeObjectDetector();
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
numPts = 0;

while 1
    videoFrame = step(vidDevice);
    videoFrameOutput = videoFrame;
    videoFrameGray = rgb2gray(videoFrame);
    if numPts < 10
        % Detection mode.
        bbox = faceDetector.step(videoFrameGray);
        if ~isempty(bbox)
            % Find corner points inside the detected region.
            points = detectMinEigenFeatures(videoFrameGray, 'ROI', bbox(1, :));
            % Re-initialize the point tracker.
            xyPoints = points.Location;
            numPts = size(xyPoints,1);
            release(pointTracker);
            initialize(pointTracker, xyPoints, videoFrameGray);
            % Save a copy of the points.
            oldPoints = xyPoints;
            % Convert the rectangle represented as [x, y, w, h] into an
            % M-by-2 matrix of [x,y] coordinates of the four corners. This
            % is needed to be able to transform the bounding box to display
            % the orientation of the face.
            bboxPoints = bbox2points(bbox(1, :));
            % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
            % format required by insertShape.
            bboxPolygon = reshape(bboxPoints', 1, []);
            % Display a bounding box around the detected face.
            videoFrameOutput = insertShape(videoFrameOutput, 'Polygon', bboxPolygon, 'LineWidth', 3);
            % Display detected corners.
            %videoFrameOutput = insertMarker(videoFrameOutput, xyPoints, '+', 'Color', 'white');
        end
    else
        % Tracking mode.
        [xyPoints, isFound] = step(pointTracker, videoFrameGray);
        visiblePoints = xyPoints(isFound, :);
        oldInliers = oldPoints(isFound, :);
        numPts = size(visiblePoints, 1);
        if numPts >= 10
            % Estimate the geometric transformation between the old points
            % and the new points.
            [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
                oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
            % Apply the transformation to the bounding box.
            bboxPoints = transformPointsForward(xform, bboxPoints);
            % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
            % format required by insertShape.
            bboxPolygon = reshape(bboxPoints', 1, []);
            % Display a bounding box around the face being tracked.
            videoFrameOutput = insertShape(videoFrameOutput, 'Polygon', bboxPolygon, 'LineWidth', 3);
            % Display tracked points.
            %videoFrameOutput = insertMarker(videoFrameOutput, visiblePoints, '+', 'Color', 'white');
            % Reset the points.
            oldPoints = visiblePoints;
            setPoints(pointTracker, oldPoints);
        end
    end
    
    step(hVideoIn, videoFrame);
    step(hVideoOut, videoFrameOutput);
    if ~isOpen(hVideoOut) || ~isOpen(hVideoIn)
        break;
    end
end
release(vidDevice);
release(hVideoIn);
release(hVideoOut);
fprintf('closed\n');
close all force;
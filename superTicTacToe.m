function [] = superTicTacToe(scale,figureNumber)
% 	scale = [];
	bigWin = [];
	board = [];
	indicators = [];
	player = [];
	bigBoard = [];
	f = [];
	ax = [];
	colors = [0.9290    0.6940    0.1250; 0    0.4470    0.7410]; % rgb [orange; blue]

	% check for input args and if they're acceptable
	if nargin < 2 || isempty(figureNumber) || (~isnumeric(figureNumber) && ~ishandle(figureNumber))
		figureNumber = 1;
	end
	temp = get(0,'ScreenSize');
	if nargin<1 || ~isnumeric(scale) || isempty(scale)
		scale = temp(4)/2; % set initial scale. Used for resizing of the window
	end
	if scale <= 0
		scale = 1;
	elseif scale > temp(4)
		scale = temp(4);
	end
	
	% Initialize
	figureSetup(figureNumber);
	gameSetup();
	


	function [] = rescale(~,~)
		s = min(f.Position(4),f.Position(3));
		ax.Position(3:4) = ax.Position(3:4)*s/scale;
		ax.Position(1:2) = (f.Position(3:4)-ax.Position(3:4))/2;
		
		for i=1:length(ax.Children)
			ax.Children(i).LineWidth = ax.Children(i).LineWidth*s/scale;
			ax.Children(i).MarkerSize = ax.Children(i).MarkerSize*s/scale;
		end
		
		scale = s;
	end

	function [] = mouseClick(~,~)
		if(bigWin)
			return
		end
		a = 0:scale/9:scale;
		m = f.CurrentPoint;
		m(1) = m(1) - ax.Position(1);
		m(2) = m(2) - ax.Position(2);
		x = find(m(1)>a,1,'last');
		y = 10-find(m(2)>a,1,'last');
		if(m(1)<a(end) && m(2)<a(end) && strcmp(indicators(y,x).Visible,'on'))
			board(y,x) = player;
			c = 'ox';
			
			plot(x-1/2,y-1/2,c(player*0.5+1.5),'MarkerSize',35*scale/650,'LineWidth',3*scale/650,'MarkerEdgeColor',colors(player*0.5+1.5,:));


			w = littleWinCheck(x,y);
			if(w)
				%draw lines

				a = ceil(x/3);
				b = ceil(y/3);

				if(player==1) % draw big letters. not done with markers because marker edge size is limited to '6'
					%draw x
					plot([3*a-2.6 3*a-0.4],[3*b-2.6 3*b-0.4],'LineWidth',18*scale/650,'Color',colors(player*0.5+1.5,:));
					plot([3*a-2.6 3*a-0.4],[3*b-0.4 3*b-2.6],'LineWidth',18*scale/650,'Color',colors(player*0.5+1.5,:));
				else
					t = linspace(0,2*pi+pi/24,50);
					r = 1.2;
					a2 = r*cos(t)+(a-0.5)*3;
					b2 = r*sin(t)+(b-0.5)*3; 
					plot(a2,b2,'LineWidth',18*scale/650,'Color',colors(player*0.5+1.5,:));
				end

				bigBoard(b,a) = player;
				bigWin = check(a,b,bigBoard);
			end
			if(bigWin)
				for i=1:numel(indicators)
					indicators(i).Visible = 'off';
				end
			else
				showMoves(x,y,w); % If a win - free move
				player = -player;
				for i=1:numel(indicators)
					indicators(i).FaceColor = colors(player*0.5+1.5,:);
				end
			end
		end
	end

	function [] = showMoves(x,y,w)

		a = mod(x,3)+3*(1-sign(mod(x,3)));
		b = mod(y,3)+3*(1-sign(mod(y,3)));
	% 	disp([x,y,a,b,bigBoard(b,a)])

		if(w || bigBoard(b,a)~=0)
			for i=1:numel(indicators)
				if(board(i)==0)
					indicators(i).Visible='on';
				else
					indicators(i).Visible='off';
				end
			end		

		else
			for i=1:numel(indicators)
				indicators(i).Visible = 'off';
			end

			for i=(1:3) + 3*(a-1)
				for j=(1:3) + 3*(b-1)
					if(board(j,i)==0)
						indicators(j,i).Visible = 'on';
					end
				end
			end
		end
		[r,c] = find(bigBoard~=0);
		if(~isempty(r))
			for i=1:length(r)
				for k=(1:3) + 3*(c(i)-1)
					for j=(1:3) + 3*(r(i)-1)
						indicators(j,k).Visible = 'off';
					end
				end
			end
		end
	end

	function [w] = littleWinCheck(x,y)

		a = 4:6;
		b = 4:6;
		if(x<4)
			a = 1:3;
		elseif(x>6)
			a = 7:9;
		end
		if(y<4)
			b = 1:3;
		elseif(y>6)
			b = 7:9;
		end
		w = check(mod(x,3)+3*(1-sign(mod(x,3))), mod(y,3)+3*(1-sign(mod(y,3))), board(b,a));
	end

	function [w] = check(x,y,b)
		w = true;
		p = b(y,x)*3;
		if(sum(b(:,x)) == p || sum(b(y,:)) == p)
			return
		end
		if(sum(b([1 5 9])) == p || sum(b([3 5 7])) == p) % not needed if x or t is even
			return
		end
		w = false;
	end

	function [] = gameSetup()
		board = zeros(9,9);
		bigBoard = zeros(3,3);
		player = 1;
		bigWin = false;

		for i=1:numel(indicators)
			indicators(i).Visible = 'on';
		end
	end

	function [] = figureSetup(fignum)
		f = figure(fignum);
		clf
		f.SizeChangedFcn = ' ';
		f.MenuBar = 'none';
		f.Name = 'Super Tic Tac Toe';
		f.NumberTitle = 'off';

		s = get(0,'ScreenSize');
		w = scale;
		h = w;
		f.Position = [(s(3)-w)/2 (s(4)-h)/2, w h];

		f.WindowButtonUpFcn = @mouseClick;
		f.SizeChangedFcn = @rescale;
		f.Resize = 'on';

		ax = axes('Parent',f);
		cla
		ax.Units = 'pixels';
		ax.Position = [0 0, w h];
		ax.XTick = [];
		ax.YTick = [];
		ax.Box = 'off';
		ax.YDir = 'reverse';
		ax.XColor = [1 1 1];
		ax.YColor = [1 1 1];
		axis equal
		hold on

		w = 9;
		h = 9;
		indicators = patch;
		delete(indicators(1));
		for i=1:9
			for j=1:9
				indicators(j,i) = patch([0.1 0.1 0.9 0.9]+(i-1),[0.1 .9 .9 0.1]+(j-1),1,'FaceColor',colors(2,:),'FaceAlpha',0.5,'LineWidth',0.5*scale/650);
			end
		end

		for i=1:8
			if(mod(i,3)==0)
				line([0 w], [i i],'LineWidth',5*scale/650);
				line([i i], [0 h],'LineWidth',5*scale/650);
			else
				line([0 w], [i i],'LineWidth',0.5*scale/650);
				line([i i], [0 h],'LineWidth',0.5*scale/650);
			end
		end
	end
end
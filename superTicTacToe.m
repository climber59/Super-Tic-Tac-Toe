%{
add "new game" somewhere so you don't have to rerun and then resize

though difficult to do, if forced to go in a filled and tied subgrid, it
shows no legal moves
%}
function [] = superTicTacToe(scale,figureNumber)
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
	


	% handles resizing everything appropriately
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

	% handles clicks
	function [] = mouseClick(~,~)
		if(bigWin)
			return % do nothing if game is over
		end
		
		% determines which grid square the user clicked
		a = 0:scale/9:scale;
		m = f.CurrentPoint;
		m(1) = m(1) - ax.Position(1);
		m(2) = m(2) - ax.Position(2);
		x = find(m(1)>a,1,'last');
		y = 10-find(m(2)>a,1,'last');
		if(m(1)<a(end) && m(2)<a(end) && strcmp(indicators(y,x).Visible,'on')) % checks that it was within the grid and if it was a legal move
			board(y,x) = player;
			c = 'ox';
			pind = player*0.5+1.5; % player index
			
			line(x-1/2,y-1/2,'Marker',c(pind),'MarkerSize',35*scale/650,'LineWidth',3*scale/650,'MarkerEdgeColor',colors(pind,:));


			littleWin = littleWinCheck(x,y); % check if this move won a subgrid
			if(littleWin)
				%draw lines
				a = ceil(x/3);
				b = ceil(y/3);

				if(player==1) % draw big letters. not done with markers because marker edge size is limited to '6'
					%draw x
					line([3*a-2.6 3*a-0.4],[3*b-2.6 3*b-0.4],'LineWidth',18*scale/650,'Color',colors(pind,:));
					line([3*a-2.6 3*a-0.4],[3*b-0.4 3*b-2.6],'LineWidth',18*scale/650,'Color',colors(pind,:));
				else
					t = linspace(0,2*pi+pi/24,50);
					r = 1.2;
					a2 = r*cos(t)+(a-0.5)*3;
					b2 = r*sin(t)+(b-0.5)*3; 
					line(a2,b2,'LineWidth',18*scale/650,'Color',colors(pind,:));
				end

				bigBoard(b,a) = player;
				bigWin = check(a,b,bigBoard); % check to see if this subgrid win also wins the whole game
			end
			if(bigWin)
				for i=1:numel(indicators)
					indicators(i).Visible = 'off';
				end
			else
				showMoves(x,y,littleWin); % show legal moves
				player = -player;
				for i=1:numel(indicators)
					indicators(i).FaceColor = colors(player*0.5+1.5,:);
				end
			end
		end
	end

	% show legal moves. turns the indicators on and off
	function [] = showMoves(x,y,w)
		a = mod(x,3)+3*(1-sign(mod(x,3)));
		b = mod(y,3)+3*(1-sign(mod(y,3)));

		if(w || bigBoard(b,a)~=0) % previous move won a subgrid or corresponds to an already won/filled subgrid
			for i=1:numel(indicators)
				if(board(i)==0)
					indicators(i).Visible='on'; %turn on all unfilled squares
				else
					indicators(i).Visible='off';
				end
			end
			[r,c] = find(bigBoard~=0);
			if(~isempty(r))
				for i=1:length(r)
					for k=(1:3) + 3*(c(i)-1)
						for j=(1:3) + 3*(r(i)-1)
							indicators(j,k).Visible = 'off'; % turn filled subgrids back off
						end
					end
				end
			end
		else
			for i=1:numel(indicators)
				indicators(i).Visible = 'off';
			end
			for i=(1:3) + 3*(a-1) 
				for j=(1:3) + 3*(b-1)
					if(board(j,i)==0)
						indicators(j,i).Visible = 'on'; % turn on unfilled indicators in the correct subgrid
					end
				end
			end
		end
	end

	% checks the 3x3 'b' for a win
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
	
	% sets up the inputs needed to make check() work on a subgrid
	function [w] = littleWinCheck(x,y)
		a = (1:3) + 3*(ceil(x/3)-1);
		b = (1:3) + 3*(ceil(y/3)-1);
		w = check(mod(x,3)+3*(1-sign(mod(x,3))), mod(y,3)+3*(1-sign(mod(y,3))), board(b,a));
	end

	% starts a new game
	function [] = gameSetup()
		board = zeros(9,9);
		bigBoard = zeros(3,3);
		player = 1;
		bigWin = false;

		for i=1:numel(indicators)
			indicators(i).Visible = 'on';
			indicators(i).FaceColor = colors(player*0.5+1.5,:);
		end
	end

	function [] = figureSetup(fignum)
		f = figure(fignum);
		clf('reset')
		f.MenuBar = 'none';
		f.Name = 'Super Tic Tac Toe';
		f.NumberTitle = 'off';

		s = get(0,'ScreenSize');
		f.Position = [(s(3)-scale)/2 (s(4)-scale)/2, scale scale];

		f.WindowButtonUpFcn = @mouseClick;
		f.SizeChangedFcn = @rescale;
		f.Resize = 'on';

		ax = axes('Parent',f);
		cla
		ax.Units = 'pixels';
		ax.Position = [0 0, scale scale];
		ax.XTick = [];
		ax.YTick = [];
		ax.Box = 'on';
		ax.YDir = 'reverse';
		ax.XColor = [1 1 1];
		ax.YColor = [1 1 1];
		axis equal
		hold on

		
		indicators = patch;
		delete(indicators(1));
		for i=1:9
			for j=1:9
				indicators(j,i) = patch([0.1 0.1 0.9 0.9]+(i-1),[0.1 .9 .9 0.1]+(j-1),1,'FaceColor',colors(2,:),'FaceAlpha',0.5,'LineWidth',0.5*scale/650);
			end
		end

		for i=1:8
			if(mod(i,3)==0)
				line([0 9], [i i],'LineWidth',5*scale/650);
				line([i i], [0 9],'LineWidth',5*scale/650);
			else
				line([0 9], [i i],'LineWidth',0.5*scale/650);
				line([i i], [0 9],'LineWidth',0.5*scale/650);
			end
		end
	end
end
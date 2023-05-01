-- Round a number to the nearest integer or specified number
-- Quickly thrown together by Dark-Assassin

math.round = function(number, to)
	if (to == nil) then
		to = 1.0;
	end
	return math.floor((number + (to / 2.0)) / to) * to;
end
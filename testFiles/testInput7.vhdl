entity ent IS
END;

ARCHITECTURE arch OF ent IS
	SIGNAL s11 : t1;
	SIGNAL s12 : t1;
	SIGNAL s2 : t2;
BEGIN
	s11 <= s2;
END;

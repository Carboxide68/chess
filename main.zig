const std = @import("std");

fn Coord(comptime T: type) type {
    if (@TypeOf(T) != i8 or @TypeOf(T) != u8) @compileError("Needs to be one of 2 types!");
    return struct {
        linear: T,

        inline fn from(x: T, y: T) Coord(T) {
            return .{.linear=x + y * 8};
        }

        inline fn x(self: Coord(T)) T {
            if (@TypeOf(T) == i8) {
                return rem(i8, self.linear, 8);
            } else {
                return self.linear & 7;
            }
        }

        inline fn y(self: Coord(T)) T {
            if (@TypeOf(T) == i8) {
                return @divFloor(self.linear, 8);
            } else {
                return self.linear >> 3;
            }
        }
    };
}

const Color = enum(u2) {
    None = 0,
    Black = 1,
    White = 2,

    pub fn is(self: Color, other: Color) bool {

        if (self == .None) return false;
        if (self == other) return true;
        return false;

    }
};

const PieceType = enum(u6) {

    Blank,

    Kn,
    B,
    P,
    Q,
    K,
    R,

};

const Piece = packed struct {

    color: Color,
    piece: PieceType,
    pub fn getMoves(self: Piece, pos: Coord(u8), board: Board, out: [*]u8) u8 {
        return switch(self.piece) {
            .Kn => knFn(self, pos, board, out),
            .B  => bFn(self, pos, board, out),
            .P  => pFn(self, pos, board, out),
            .Q  => qFn(self, pos, board, out),
            .K  => kFn(self, pos, board, out),
            .R  => rFn(self, pos, board, out),
            _ => 0,
        };
    }

    const blank = Piece{.color=.None, .piece=.Blank};

    const bKn = Piece{.color=.Black, .piece=.Kn};
    const bB  = Piece{.color=.Black, .piece=.B};
    const bP  = Piece{.color=.Black, .piece=.P};
    const bQ  = Piece{.color=.Black, .piece=.Q};
    const bK  = Piece{.color=.Black, .piece=.K};

    const wKn = Piece{.color=.White, .piece=.Kn};
    const wB  = Piece{.color=.White, .piece=.B};
    const wP  = Piece{.color=.White, .piece=.P};
    const wQ  = Piece{.color=.White, .piece=.Q};
    const wK  = Piece{.color=.White, .piece=.K};


    fn knFn(self: Piece, pos: Coord(u8), board: Board, out: [*]u8) u8 {
        const possible_moves = [8]i8 = {-17, -15, -10, -6, 6, 10, 15, 17};
        const coords = @ptrCast(*const [8]Coord(i8), &(possible_moves));

        var i: u8 = 0;
        for (coords) |coord| {
            if (Board.isOutside(pos, coord)) continue;
            const new_coord = Coord(u8){.linear=coord.linear + pos.linear};
            if (board[new_coord.linear].color.is(self.color)) continue;
            out[i] = new_coord.linear;
            i += 1;
        }
        return i;
    }

    fn bFn(self: Piece, pos: Coord(u8), board: Board, out: [*]u8) void {

        var move_size: u8 = 0;

        const min = std.math.min(pos.x(), pos.y());
        const dirs = [_]i8{-7, -9, 9, 7};
        var i: u8 = 0;
        for (dirs) |dir| {
            var new_pos = pos.linear + dir;
            while (!Board.isOutside(.{.linear=new_pos})) : (new_pos += dir) {
                if (board[new_pos.linear].piece == .Blank) {out[i] = new_pos; i+=1; continue;}
                if (board[new_pos.linear].color == self.color) {break;}
                out[i] = new_pos; i+=1; break;
            }
        }
        return i;
    }

    fn pFn(self: Piece, pos: Coord(u8), board: Board, out: [*]u8) u8 {
        out[0] = if (self.color == .Black) -8 else 8;
        var i: u8 = 1;
        if (self.color == .Black) {
            if (board.white2step == pos.linear - 9) {out[i] = pos.linear-9; i+=1;}
            if (board.white2step == pos.linear - 7) {out[i] = pos.linear-7; i+=1;}
        } else {
            if (board.black2step == pos.linear - 9) {out[i] = pos.linear-9; i+=1;}
            if (board.black2step == pos.linear - 7) {out[i] = pos.linear-7; i+=1;}        }
        return i;
    }

    fn qFn(self: Piece, pos: Coord(u8), board: Board, out: [*]u8) u8 {
        var i: u8 = 0;
        for (coords) |coord| {
            if (Board.isOutside(pos, coord)) continue;
            const new_coord = Coord(u8){.linear=coord.linear + pos.linear};
            if (board[new_coord.linear].color.is(self.color)) continue;
            out[i] = new_coord.linear;
            i += 1;
        }
        return i;
    }

    fn kFn(self: Piece, pos: Coord(u8), board: Board, out: [*]u8) u8 {
        var i: u8 = 0;
        for (coords) |coord| {
            if (Board.isOutside(pos, coord)) continue;
            const new_coord = Coord(u8){.linear=coord.linear + pos.linear};
            if (board[new_coord.linear].color.is(self.color)) continue;
            out[i] = new_coord.linear;
            i += 1;
        }
        return i;
    }

};

const Board = struct {

    board: [64]Piece = STANDARD_CHESS_BOARD,
    white2step: u8 = 255,
    black2step: u8 = 255,

    pub fn load(fen: []u8) Board {

    }

    pub fn isOutside(start: Coord(u8), move: Coord(i8)) {
        
        const x = start.x() + move.x();
        if (x > 7 || x < 0) return true;
        const y = start.y() + move.y();
        if (y > 7 || y < 0) return true;
        return true;

    }

    const STANDARD_CHESS_BOARD = Board.load("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR");

};
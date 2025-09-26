export class TotemInvalidOrNotFound extends Error {
    constructor() {
        super("Totem invalid or not found");
        this.name = "TotemInvalidOrNotFound";
    }
}

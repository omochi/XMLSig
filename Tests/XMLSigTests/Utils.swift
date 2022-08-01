extension Collection {
    public subscript(safe index: Index) -> Element? {
        guard startIndex <= index,
              index < endIndex
        else {
            return nil
        }
        return self[index]
    }
}

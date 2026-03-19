import Foundation

final class UserProgressService {
    private let key = "com.tumblox.userProgress"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func load() -> UserProgress {
        guard let data = UserDefaults.standard.data(forKey: key),
              let progress = try? decoder.decode(UserProgress.self, from: data)
        else { return UserProgress() }
        return progress
    }

    func save(_ progress: UserProgress) {
        guard let data = try? encoder.encode(progress) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    func reset() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

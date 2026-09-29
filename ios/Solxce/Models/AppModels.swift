// Models/AppModels.swift
import Foundation
import SwiftData

// MARK: - Exercise Set
@Model
final class ExerciseSet {
    var id: UUID
    var setNumber: Int
    var reps: Int
    var weightLbs: Double
    var isCompleted: Bool

    init(id: UUID = UUID(), setNumber: Int, reps: Int, weightLbs: Double, isCompleted: Bool = true) {
        self.id = id
        self.setNumber = setNumber
        self.reps = reps
        self.weightLbs = weightLbs
        self.isCompleted = isCompleted
    }
}

// MARK: - Workout Exercise
@Model
final class WorkoutExercise {
    var id: UUID
    var name: String
    var targetMuscle: String
    @Relationship(deleteRule: .cascade) var sets: [ExerciseSet]

    init(id: UUID = UUID(), name: String, targetMuscle: String, sets: [ExerciseSet] = []) {
        self.id = id
        self.name = name
        self.targetMuscle = targetMuscle
        self.sets = sets
    }
}

// MARK: - Workout Session
@Model
final class WorkoutSession {
    var id: UUID
    var title: String
    var bodyPartFocus: String
    var date: Date
    var durationMinutes: Int
    @Relationship(deleteRule: .cascade) var exercises: [WorkoutExercise]

    init(
        id: UUID = UUID(),
        title: String,
        bodyPartFocus: String,
        date: Date = Date(),
        durationMinutes: Int = 45,
        exercises: [WorkoutExercise] = []
    ) {
        self.id = id
        self.title = title
        self.bodyPartFocus = bodyPartFocus
        self.date = date
        self.durationMinutes = durationMinutes
        self.exercises = exercises
    }

    var totalVolumeLbs: Double {
        exercises.reduce(0) { sum, exercise in
            sum + exercise.sets.reduce(0) { setSum, set in
                setSum + (Double(set.reps) * set.weightLbs)
            }
        }
    }

    var totalSets: Int {
        exercises.reduce(0) { $0 + $1.sets.count }
    }
}

// MARK: - Run Entry
@Model
final class RunEntry {
    var id: UUID
    var title: String
    var distanceMiles: Double
    var durationSeconds: Int
    var date: Date
    var caloriesBurned: Int
    var notes: String

    init(
        id: UUID = UUID(),
        title: String = "Outdoor Run",
        distanceMiles: Double,
        durationSeconds: Int,
        date: Date = Date(),
        caloriesBurned: Int = 0,
        notes: String = ""
    ) {
        self.id = id
        self.title = title
        self.distanceMiles = distanceMiles
        self.durationSeconds = durationSeconds
        self.date = date
        self.caloriesBurned = caloriesBurned > 0 ? caloriesBurned : Int(distanceMiles * 110)
        self.notes = notes
    }

    var paceMinutesPerMile: Double {
        guard distanceMiles > 0 else { return 0 }
        return (Double(durationSeconds) / 60.0) / distanceMiles
    }

    var formattedPace: String {
        let pace = paceMinutesPerMile
        let mins = Int(pace)
        let secs = Int((pace - Double(mins)) * 60)
        return String(format: "%d'%02d\" /mi", mins, secs)
    }

    var formattedDuration: String {
        let mins = durationSeconds / 60
        let secs = durationSeconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Food Entry
@Model
final class FoodEntry {
    var id: UUID
    var name: String
    var mealType: String // Breakfast, Lunch, Dinner, Snack
    var calories: Int
    var proteinGrams: Int
    var carbsGrams: Int
    var fatGrams: Int
    var date: Date

    init(
        id: UUID = UUID(),
        name: String,
        mealType: String = "Snack",
        calories: Int,
        proteinGrams: Int,
        carbsGrams: Int,
        fatGrams: Int,
        date: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.mealType = mealType
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatGrams = fatGrams
        self.date = date
    }
}

// MARK: - Macro Target
@Model
final class MacroTarget {
    var id: UUID
    var dailyCalories: Int
    var dailyProteinGrams: Int
    var dailyCarbsGrams: Int
    var dailyFatGrams: Int

    init(
        id: UUID = UUID(),
        dailyCalories: Int = 2400,
        dailyProteinGrams: Int = 180,
        dailyCarbsGrams: Int = 240,
        dailyFatGrams: Int = 70
    ) {
        self.id = id
        self.dailyCalories = dailyCalories
        self.dailyProteinGrams = dailyProteinGrams
        self.dailyCarbsGrams = dailyCarbsGrams
        self.dailyFatGrams = dailyFatGrams
    }
}

// MARK: - Planner Day
@Model
final class PlannerDay {
    var id: UUID
    var dayOfWeek: Int // 1 = Sunday, 2 = Monday, ... 7 = Saturday
    var dayName: String
    var focusBodyPart: String
    var isRestDay: Bool
    var targetExercisesDescription: String

    init(
        id: UUID = UUID(),
        dayOfWeek: Int,
        dayName: String,
        focusBodyPart: String,
        isRestDay: Bool = false,
        targetExercisesDescription: String = ""
    ) {
        self.id = id
        self.dayOfWeek = dayOfWeek
        self.dayName = dayName
        self.focusBodyPart = focusBodyPart
        self.isRestDay = isRestDay
        self.targetExercisesDescription = targetExercisesDescription
    }
}

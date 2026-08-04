// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.ids

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import okhttp3.FormBody
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject
import java.util.Base64
import kotlin.math.exp
import kotlin.math.max
import kotlin.math.min
import kotlin.random.Random

class CaptchaSolveFailedException : Exception("验证码校验失败")

data class TrackPoint(val a: Int, val b: Int, val c: Int)

/**
 * Automatic slider captcha solver for ids.xidian.edu.cn.
 * Ports the Flutter Wear [SliderCaptchaClientProvider] NCC matcher + track generator.
 */
class SliderCaptchaClient(
    private val client: OkHttpClient,
    private val cookieHeader: String,
) {
    private var puzzleData: ByteArray? = null
    private var pieceData: ByteArray? = null
    private val puzzleWidth = 280

    suspend fun solveAutomatically() {
        Log.i(TAG, "Trying automatic slider captcha solve.")
        var lastError: Exception? = null
        for (attempt in 0 until 5) {
            try {
                if (solveOnce()) return
            } catch (e: Exception) {
                lastError = e
                Log.w(TAG, "Automatic slider captcha solve failed.", e)
                if (attempt < 4) {
                    kotlinx.coroutines.delay((attempt + 1) * 1000L)
                }
            }
        }
        throw lastError ?: CaptchaSolveFailedException()
    }

    private suspend fun solveOnce(): Boolean {
        updatePuzzle()
        val puzzleBytes = puzzleData ?: return false
        val pieceBytes = pieceData ?: return false
        val puzzle = BitmapFactory.decodeByteArray(puzzleBytes, 0, puzzleBytes.size)
            ?: return false
        val piece = BitmapFactory.decodeByteArray(pieceBytes, 0, pieceBytes.size)
            ?: return false
        try {
            val solvedOffset = solveSlideOffset(puzzle, piece, border = 24)
            val baseMove = solvedOffset * puzzleWidth / puzzle.width
            for (delta in intArrayOf(1, -1, 2, -2, 3, -3, 4)) {
                val move = baseMove + delta
                if (move < 0 || move > puzzleWidth) continue
                val tracks = generateAutoTracks(move)
                val waitMs = max(0, tracks.last().c - 100)
                kotlinx.coroutines.delay(waitMs.toLong())
                if (verifyWithTracks(tracks)) return true
            }
            return false
        } finally {
            puzzle.recycle()
            piece.recycle()
        }
    }

    private fun updatePuzzle() {
        val url =
            "https://ids.xidian.edu.cn/authserver/common/openSliderCaptcha.htl" +
                "?_=${System.currentTimeMillis()}"
        val request = Request.Builder()
            .url(url)
            .header("Cookie", cookieHeader)
            .get()
            .build()
        client.newCall(request).execute().use { response ->
            val body = response.body?.string()
                ?: throw CaptchaSolveFailedException()
            val json = JSONObject(body)
            puzzleData = Base64.getDecoder().decode(json.getString("bigImage"))
            pieceData = Base64.getDecoder().decode(json.getString("smallImage"))
        }
    }

    private fun verifyWithTracks(tracks: List<TrackPoint>): Boolean {
        val moveLength = tracks.lastOrNull()?.a ?: 0
        val tracksJson = tracks.joinToString(
            prefix = "[",
            postfix = "]",
        ) { """{"a":${it.a},"b":${it.b},"c":${it.c}}""" }
        val payload =
            """{"canvasLength":$puzzleWidth,"moveLength":$moveLength,"tracks":$tracksJson}"""
        val piece = pieceData ?: throw CaptchaSolveFailedException()
        val sign = IdsCrypto.encryptCaptchaPayload(payload, piece)
        val form = FormBody.Builder()
            .add("sign", sign)
            .build()
        val request = Request.Builder()
            .url("https://ids.xidian.edu.cn/authserver/common/verifySliderCaptcha.htl")
            .header("Cookie", cookieHeader)
            .header("Accept", "application/json, text/javascript, */*; q=0.01")
            .header("Origin", "https://ids.xidian.edu.cn")
            .header("X-Requested-With", "XMLHttpRequest")
            .post(form)
            .build()
        client.newCall(request).execute().use { response ->
            val body = response.body?.string() ?: return false
            val json = JSONObject(body)
            return json.optString("errorMsg") == "success" || json.optInt("errorCode") == 1
        }
    }

    companion object {
        private const val TAG = "SliderCaptcha"

        fun solveSlideOffset(puzzle: Bitmap, piece: Bitmap, border: Int = 24): Int {
            val bbox = nrgbaBbox(piece)
            var xL = bbox[0] + border
            var yT = bbox[1] + border
            var xR = bbox[2] - border
            var yB = bbox[3] - border
            if (xL < 0 || yT < 0 || xR < xL || yB < yT) {
                throw CaptchaSolveFailedException()
            }
            val windowWidth = xR - xL + 1
            val windowHeight = yB - yT + 1
            val bigWidth = puzzle.width - piece.width + windowWidth
            if (windowWidth <= 0 || windowHeight <= 0 || bigWidth < windowWidth ||
                xL + windowWidth > piece.width || yT + windowHeight > piece.height ||
                xL + bigWidth > puzzle.width || yT + windowHeight > puzzle.height
            ) {
                throw CaptchaSolveFailedException()
            }

            val templateGray = grayFromImage(piece, xL, yT, windowWidth, windowHeight)
            val templateMean =
                graySum(templateGray, 0, 0, windowWidth, windowHeight) /
                    (windowWidth * windowHeight).toDouble()
            val template = grayNorm(
                templateGray, 0, 0, windowWidth, windowHeight, templateMean,
            )
            val puzzleGray = grayFromImage(puzzle, xL, yT, bigWidth, windowHeight)
            val columnSums = DoubleArray(bigWidth) { x ->
                graySum(puzzleGray, x, 0, 1, windowHeight)
            }

            var windowSum = 0.0
            for (x in 0 until windowWidth) windowSum += columnSums[x]
            val area = (windowWidth * windowHeight).toDouble()
            var maxScore = grayNccFast(
                puzzleGray, 0, 0, windowWidth, windowHeight, windowSum / area, template,
            )
            var bestX = 0
            for (x in 1 until bigWidth - windowWidth) {
                windowSum += columnSums[x + windowWidth - 1] - columnSums[x - 1]
                val score = grayNccFast(
                    puzzleGray, x, 0, windowWidth, windowHeight, windowSum / area, template,
                )
                if (score > maxScore) {
                    maxScore = score
                    bestX = x
                }
            }
            return bestX
        }

        private fun nrgbaBbox(image: Bitmap): IntArray {
            var xL = image.width
            var yT = image.height
            var xR = 0
            var yB = 0
            var found = false
            val pixels = IntArray(image.width * image.height)
            image.getPixels(pixels, 0, image.width, 0, 0, image.width, image.height)
            for (y in 0 until image.height) {
                for (x in 0 until image.width) {
                    val a = (pixels[y * image.width + x] ushr 24) and 0xFF
                    if (a == 255) {
                        found = true
                        if (x < xL) xL = x
                        if (y < yT) yT = y
                        if (x > xR) xR = x
                        if (y > yB) yB = y
                    }
                }
            }
            if (!found) throw CaptchaSolveFailedException()
            return intArrayOf(xL, yT, xR, yB)
        }

        private data class GrayImage(val pixels: IntArray, val stride: Int)

        private fun grayFromImage(
            image: Bitmap,
            xL: Int,
            yT: Int,
            width: Int,
            height: Int,
        ): GrayImage {
            val pixels = IntArray(width * height)
            var index = 0
            for (y in yT until yT + height) {
                for (x in xL until xL + width) {
                    val color = image.getPixel(x, y)
                    val r = (color shr 16) and 0xFF
                    val g = (color shr 8) and 0xFF
                    val b = color and 0xFF
                    pixels[index++] = (77 * r + 150 * g + 29 * b) shr 8
                }
            }
            return GrayImage(pixels, width)
        }

        private fun graySum(
            gray: GrayImage,
            xL: Int,
            yT: Int,
            width: Int,
            height: Int,
        ): Double {
            var sum = 0.0
            for (y in yT until yT + height) {
                val row = y * gray.stride
                for (x in xL until xL + width) {
                    sum += gray.pixels[row + x]
                }
            }
            return sum
        }

        private fun grayNorm(
            gray: GrayImage,
            xL: Int,
            yT: Int,
            width: Int,
            height: Int,
            mean: Double,
        ): DoubleArray {
            val normalized = DoubleArray(width * height)
            var index = 0
            for (y in yT until yT + height) {
                val row = y * gray.stride
                for (x in xL until xL + width) {
                    normalized[index++] = gray.pixels[row + x] - mean
                }
            }
            return normalized
        }

        private fun grayNccFast(
            windowImage: GrayImage,
            xL: Int,
            yT: Int,
            width: Int,
            height: Int,
            mean: Double,
            template: DoubleArray,
        ): Double {
            var sumWindowTemplate = 0.0
            var sumWindowWindow = 0.0
            var index = 0
            for (y in yT until yT + height) {
                val row = y * windowImage.stride
                for (x in xL until xL + width) {
                    val window = windowImage.pixels[row + x] - mean
                    sumWindowWindow += window * window
                    sumWindowTemplate += window * template[index++]
                }
            }
            if (sumWindowWindow == 0.0) return Double.NEGATIVE_INFINITY
            return sumWindowTemplate / sumWindowWindow
        }

        fun generateAutoTracks(targetX: Int, random: Random = Random.Default): List<TrackPoint> {
            if (targetX <= 0) return listOf(TrackPoint(0, 0, 0), TrackPoint(0, 0, 0))
            val norm = 1.0 / (1.0 + 0.017248380016648118)
            val tracks = mutableListOf(TrackPoint(0, 0, 0))
            val pointCount = random.nextInt(5) + 10
            var y = 0
            for (i in 0 until pointCount) {
                val z = (1.0 / (1.0 + exp(-7.0 * (i / pointCount.toDouble() - 0.42)))) / norm
                val previousX = tracks.last().a
                val x = min(targetX - 1, max(previousX + 1, (targetX * z).toInt()))
                val drift = random.nextDouble()
                when {
                    drift < 0.65 -> y--
                    drift < 0.80 -> y++
                }
                y = max(-10, min(10, y))
                tracks += TrackPoint(x, y, random.nextInt(701) + 900)
            }
            tracks += TrackPoint(targetX, y, random.nextInt(701) + 900)
            return tracks
        }
    }
}
